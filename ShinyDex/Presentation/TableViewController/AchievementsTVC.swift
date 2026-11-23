import UIKit

final class AchievementsTVC: UITableViewController {
    fileprivate let container: AppContainer
    fileprivate var sections = [(title: String, achievements: [Achievement])]()
    fileprivate let unlockedTile = StatTile(caption: "UNLOCKED")
    fileprivate let tiersTile = StatTile(caption: "TIERS EARNED")

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Achievements"
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(AchievementCell.self, forCellReuseIdentifier: AchievementCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAchievements()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layOutHeader()
    }

    fileprivate func reloadAchievements() {
        let overview = container.getAchievements.handle(GetAchievementsQuery())
        let grouped = Dictionary(grouping: overview.achievements, by: { $0.category })
        let categories = AchievementCategory.allCases.compactMap { category -> (title: String, achievements: [Achievement])? in
            guard let achievements = grouped[category] else { return nil }
            return ("\(category.title) · \(achievements.filter { $0.isUnlocked }.count)/\(achievements.count)", achievements)
        }
        let nextUp = overview.nextUp
        sections = (nextUp.isEmpty ? [] : [("Next up", nextUp)]) + categories
        unlockedTile.setValue("\(overview.unlockedCount) / \(overview.achievements.count)")
        tiersTile.setValue("\(overview.unlockedTierCount) / \(overview.tierCount)")
        tableView.reloadData()
        layOutHeader()
    }

    fileprivate func layOutHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let header = (tableView.tableHeaderView as? AchievementsHeaderView) ?? AchievementsHeaderView(tiles: [unlockedTile, tiersTile])
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard tableView.tableHeaderView !== header || header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    // MARK: Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].achievements.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: sections[section].title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AchievementCell.reuseIdentifier, for: indexPath) as! AchievementCell
        cell.configure(achievement: sections[indexPath.section].achievements[indexPath.row], showsDisclosure: true)
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return !sections[indexPath.section].achievements[indexPath.row].isSecret
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let achievement = sections[indexPath.section].achievements[indexPath.row]
        guard !achievement.isSecret else { return }
        navigationController?.pushViewController(AchievementDetailTVC(container: container, kind: achievement.kind), animated: true)
    }
}

final class AchievementsHeaderView: UIView {
    init(tiles: [UIView]) {
        super.init(frame: .zero)
        let row = UIStackView(arrangedSubviews: tiles)
        row.distribution = .fillEqually
        row.spacing = Spacing.medium
        addAutoLayoutSubviews(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.screenMargin, bottom: Spacing.small, right: Spacing.screenMargin))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
