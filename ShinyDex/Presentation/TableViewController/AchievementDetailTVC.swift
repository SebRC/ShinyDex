import UIKit

final class AchievementDetailTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case summary
        case tiers
        case catches
    }

    fileprivate let container: AppContainer
    fileprivate let kind: AchievementKind
    fileprivate var details: AchievementDetails?
    fileprivate let tierCellIdentifier = "achievementTierCell"

    init(container: AppContainer, kind: AchievementKind) {
        self.container = container
        self.kind = kind
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(AchievementCell.self, forCellReuseIdentifier: AchievementCell.reuseIdentifier)
        tableView.register(CatchCell.self, forCellReuseIdentifier: CatchCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        details = container.getAchievementDetails.handle(GetAchievementDetailsQuery(kind: kind))
        title = details?.achievement.title
        tableView.reloadData()
        updateEmptyState()
    }

    fileprivate var tierTargets: [Int] {
        guard let targets = details?.achievement.targets, targets.count > 1 else { return [] }
        return targets
    }

    fileprivate func updateEmptyState() {
        tableView.backgroundView = details == nil ? EmptyStateView(symbolName: "medal", title: "Not found", message: "This achievement is no longer available.") : nil
    }

    // MARK: Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return details == nil ? 0 : Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .summary: return 1
        case .tiers: return tierTargets.count
        case .catches: return details?.catches.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: makeHeaderTitle(for: Section(rawValue: section)!))
    }

    fileprivate func makeHeaderTitle(for section: Section) -> String? {
        switch section {
        case .summary: return nil
        case .tiers: return tierTargets.isEmpty ? nil : "Tiers"
        case .catches: return details?.catches.isEmpty == false ? (details?.achievement.isUnlocked == true ? "Unlocked by" : "So far") : nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return makeHeaderTitle(for: Section(rawValue: section)!) == nil ? Spacing.small : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Section(rawValue: indexPath.section) == .catches ? CatchCell.height : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let details = details else { return UITableViewCell() }
        switch Section(rawValue: indexPath.section)! {
        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: AchievementCell.reuseIdentifier, for: indexPath) as! AchievementCell
            cell.configure(achievement: details.achievement)
            return cell
        case .tiers:
            return makeTierCell(target: tierTargets[indexPath.row], tier: indexPath.row + 1, achievement: details.achievement)
        case .catches:
            let cell = tableView.dequeueReusableCell(withIdentifier: CatchCell.reuseIdentifier, for: indexPath) as! CatchCell
            let caught = details.catches[indexPath.row]
            let subtitle = [caught.nickname.map { _ in caught.speciesTitle }, caught.formattedCaughtDate, caught.encounters > 0 ? "\(caught.encounters.grouped) encounters" : nil]
                .compactMap { $0 }.joined(separator: " · ")
            cell.configure(pokemonName: caught.pokemonName, formId: caught.formId, title: caught.nickname ?? caught.speciesTitle, subtitle: subtitle, ball: caught.caughtBall, isFailed: caught.isFailed)
            return cell
        }
    }

    fileprivate func makeTierCell(target: Int, tier: Int, achievement: Achievement) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tierCellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: tierCellIdentifier)
        let isReached = achievement.value >= target
        cell.backgroundColor = Color.surface
        cell.selectionStyle = .none
        cell.textLabel?.text = "Tier \(tier)"
        cell.textLabel?.font = UIFont.make(.subheadline, weight: .semibold)
        cell.textLabel?.textColor = isReached ? Color.textPrimary : Color.textSecondary
        cell.detailTextLabel?.text = achievement.describeGoal(for: target)
        cell.detailTextLabel?.font = UIFont.make(.footnote)
        cell.detailTextLabel?.textColor = Color.textTertiary
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage.makeSymbol(isReached ? "checkmark.circle.fill" : "circle", pointSize: 20, weight: .semibold)
        cell.imageView?.tintColor = isReached ? Color.accent : Color.textQuaternary
        cell.accessibilityLabel = "Tier \(tier), \(isReached ? "reached" : "not reached"), \(achievement.describeGoal(for: target))"
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return Section(rawValue: indexPath.section) == .catches
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .catches, let caught = details?.catches[indexPath.row],
              let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }
}
