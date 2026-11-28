import UIKit

final class TeamTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case members, coverage, weaknesses
    }

    fileprivate static let cellIdentifier = "teamMemberCell"
    fileprivate static let spriteSide: CGFloat = 48

    fileprivate let container: AppContainer
    fileprivate let teamId: TeamID
    fileprivate var details: TeamDetails?
    fileprivate let membersTile = StatTile(caption: "Members")
    fileprivate let readinessTile = StatTile(caption: "Readiness")
    fileprivate let readyTile = StatTile(caption: "Battle ready")

    init(container: AppContainer, teamId: TeamID) {
        self.container = container
        self.teamId = teamId
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TeamTVC.cellIdentifier)
        tableView.register(TeamCoverageCell.self, forCellReuseIdentifier: TeamCoverageCell.reuseIdentifier)
        tableView.register(TeamWeaknessCell.self, forCellReuseIdentifier: TeamWeaknessCell.reuseIdentifier)
        let renameButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(renamePressed))
        renameButton.accessibilityLabel = "Rename team"
        navigationItem.rightBarButtonItem = renameButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTeam()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layOutHeader()
    }

    // MARK: Data

    fileprivate var hasMembers: Bool {
        return !(details?.members.isEmpty ?? true)
    }

    fileprivate func reloadTeam() {
        details = container.getTeam.handle(GetTeamQuery(teamId: teamId))
        guard let details = details else {
            navigationController?.popViewController(animated: true)
            return
        }
        title = details.name
        membersTile.setValue("\(details.members.count)/\(Team.maximumSize)", isEmphasized: details.isFull)
        readinessTile.setValue(details.averageReadiness.map(String.init) ?? "–", isEmphasized: true)
        readinessTile.setDetail("average")
        readyTile.setValue("\(details.readyCount)", isEmphasized: details.readyCount == Team.maximumSize)
        readyTile.setDetail("of \(details.members.count)")
        tableView.reloadData()
    }

    fileprivate func layOutHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let header = tableView.tableHeaderView ?? makeHeader()
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard tableView.tableHeaderView !== header || header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    fileprivate func makeHeader() -> UIView {
        let tiles = UIStackView(arrangedSubviews: [membersTile, readinessTile, readyTile])
        tiles.distribution = .fillEqually
        tiles.spacing = Spacing.medium
        let header = UIView()
        header.addAutoLayoutSubviews(tiles)
        tiles.pinEdges(to: header, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.screenMargin, bottom: Spacing.small, right: Spacing.screenMargin))
        return header
    }

    // MARK: Actions

    @objc fileprivate func renamePressed() {
        presentTextInput(title: "Rename Team", text: details?.name, placeholder: "Name") { [weak self] name in
            guard let self = self else { return }
            self.container.updateTeam.handle(UpdateTeamCommand(teamId: self.teamId, change: .rename(name)))
            self.reloadTeam()
        }
    }

    fileprivate func addMember() {
        let picker = TeamMemberPickerTVC(container: container, teamId: teamId) { [weak self] member in
            guard let self = self else { return }
            self.container.updateTeam.handle(UpdateTeamCommand(teamId: self.teamId, change: .add(member.battler.id)))
            Haptics.playSuccess()
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func remove(_ member: TeamMember) {
        container.updateTeam.handle(UpdateTeamCommand(teamId: teamId, change: .remove(member.battler.id)))
        Haptics.tap()
        reloadTeam()
    }

    // MARK: Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let details = details else { return 0 }
        switch Section(rawValue: section)! {
        case .members: return details.members.count + (details.isFull ? 0 : 1)
        case .coverage: return hasMembers ? 1 : 0
        case .weaknesses: return hasMembers ? max(details.sharedWeaknesses.count, 1) : 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: makeHeaderTitle(for: section))
    }

    fileprivate func makeHeaderTitle(for section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .members: return "Battlers"
        case .coverage: return hasMembers ? "Move coverage" : nil
        case .weaknesses: return hasMembers ? "Shared weaknesses" : nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let details = details else { return nil }
        switch Section(rawValue: section)! {
        case .members:
            return hasMembers ? "Swipe to remove a battler. Only catches with IVs logged can join a team." : "Add up to six battlers. Only catches with IVs logged can join a team."
        case .coverage:
            guard hasMembers else { return nil }
            let covered = details.coverage.filter { $0.hitters > 0 }.count
            return "Damaging moves hit \(covered) of \(details.coverage.count) types super effectively. The number shows how many battlers can. Faded types aren't covered."
        case .weaknesses:
            return hasMembers ? "Types that at least \(TeamAnalysis.sharedWeaknessMinimum) battlers are weak to, with fewer battlers resisting them." : nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let details = details else { return UITableViewCell() }
        switch Section(rawValue: indexPath.section)! {
        case .members:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamTVC.cellIdentifier, for: indexPath)
            cell.backgroundColor = Color.surface
            if let member = details.members[safe: indexPath.row] {
                cell.contentConfiguration = member.makeContentConfiguration(spriteSide: TeamTVC.spriteSide)
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.contentConfiguration = makeAddConfiguration()
                cell.accessoryType = .none
            }
            return cell
        case .coverage:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamCoverageCell.reuseIdentifier, for: indexPath) as! TeamCoverageCell
            cell.configure(coverage: details.coverage)
            return cell
        case .weaknesses:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamWeaknessCell.reuseIdentifier, for: indexPath) as! TeamWeaknessCell
            cell.configure(weakness: details.sharedWeaknesses[safe: indexPath.row])
            return cell
        }
    }

    fileprivate func makeAddConfiguration() -> UIListContentConfiguration {
        var content = UIListContentConfiguration.cell()
        content.image = UIImage(systemName: "plus.circle.fill")
        content.imageProperties.tintColor = Color.accent
        content.text = "Add battler"
        content.textProperties.font = UIFont.make(.body, weight: .semibold)
        content.textProperties.color = Color.accent
        return content
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .members, let details = details else { return }
        guard let member = details.members[safe: indexPath.row] else {
            addMember()
            return
        }
        guard let detail = CatchDetailTVC(container: container, catchId: member.battler.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .members, let member = details?.members[safe: indexPath.row] else { return nil }
        let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.remove(member)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}

final class TeamCoverageCell: UITableViewCell {
    static let reuseIdentifier = "teamCoverageCell"

    fileprivate let coverageView = TypeCoverageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        selectionStyle = .none
        contentView.addAutoLayoutSubviews(coverageView)
        coverageView.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(coverage: [TypeCoverage]) {
        coverageView.update(coverage: coverage)
    }
}

final class TeamWeaknessCell: UITableViewCell {
    static let reuseIdentifier = "teamWeaknessCell"
    static let badgeWidth: CGFloat = 92

    fileprivate let badgeSlot = UIView()
    fileprivate let detailLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.textSecondary)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        selectionStyle = .none
        detailLabel.numberOfLines = 0
        let row = UIStackView(arrangedSubviews: [badgeSlot, detailLabel])
        row.spacing = Spacing.medium
        row.alignment = .center
        contentView.addAutoLayoutSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.large, bottom: Spacing.small, right: Spacing.large))
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(weakness: TypeWeakness?) {
        badgeSlot.subviews.forEach { $0.removeFromSuperview() }
        guard let weakness = weakness else {
            badgeSlot.isHidden = true
            detailLabel.text = "No shared weaknesses"
            detailLabel.textColor = Color.textSecondary
            accessibilityLabel = detailLabel.text
            return
        }
        badgeSlot.isHidden = false
        let badge = TypeBadge(type: weakness.type)
        badgeSlot.addAutoLayoutSubviews(badge)
        badge.pinEdges(to: badgeSlot)
        badge.widthAnchor.constraint(equalToConstant: TeamWeaknessCell.badgeWidth).isActive = true
        let resists = weakness.resistCount == 0 ? "none resist" : "\(weakness.resistCount) resist\(weakness.resistCount == 1 ? "s" : "")"
        detailLabel.text = "\(weakness.weakCount) weak · \(resists)"
        detailLabel.textColor = weakness.weakCount >= 3 ? Color.danger : Color.textSecondary
        accessibilityLabel = "\(weakness.type.name): \(detailLabel.text ?? "")"
    }
}
