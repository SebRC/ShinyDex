import UIKit

final class StatRankingTVC: UITableViewController {
    fileprivate let container: AppContainer
    fileprivate let statControl = UISegmentedControl(items: Stat.allCases.map { $0.shortName })
    fileprivate let levelControl = UISegmentedControl(items: BattleLevel.allCases.map { "Lv. \($0.rawValue)" })
    fileprivate let hiddenButton = UIButton(type: .system)
    fileprivate let noteLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate var ranking = StatRanking(leaders: [], catchesWithoutIV: 0)
    fileprivate var stat = Stat.speed
    fileprivate var level: BattleLevel
    fileprivate var showsBestOfEachSpecies = false

    init(container: AppContainer, level: BattleLevel) {
        self.container = container
        self.level = level
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stat Rankings"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(StatLeaderCell.self, forCellReuseIdentifier: StatLeaderCell.reuseIdentifier)
        setUpControls()
        updateOptionsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadRanking()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layOutHeader()
    }

    fileprivate func setUpControls() {
        for control in [statControl, levelControl] {
            control.selectedSegmentTintColor = Color.accent
            control.backgroundColor = Color.surfaceRaised
            control.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.footnote, weight: .semibold)], for: .normal)
            control.setTitleTextAttributes([.foregroundColor: Color.onAccent, .font: UIFont.make(.footnote, weight: .bold)], for: .selected)
        }
        hiddenButton.isHidden = true
        statControl.selectedSegmentIndex = stat.rawValue
        statControl.accessibilityLabel = "Stat"
        statControl.addTarget(self, action: #selector(statChanged), for: .valueChanged)
        levelControl.selectedSegmentIndex = BattleLevel.allCases.firstIndex(of: level) ?? 0
        levelControl.accessibilityLabel = "Level for calculated stats"
        levelControl.addTarget(self, action: #selector(levelChanged), for: .valueChanged)
    }

    fileprivate func updateOptionsButton() {
        let bestOfEachSpecies = UIAction(title: "Best of Each Species", image: UIImage(systemName: "square.stack"), state: showsBestOfEachSpecies ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.showsBestOfEachSpecies.toggle()
            Haptics.tap()
            self.updateOptionsButton()
            self.reloadRanking()
        }
        let optionsButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: UIMenu(children: [bestOfEachSpecies]))
        optionsButton.accessibilityLabel = "Options"
        navigationItem.rightBarButtonItem = optionsButton
    }

    // MARK: Data

    fileprivate func reloadRanking() {
        ranking = container.rankByStat.handle(RankByStatQuery(stat: stat, level: level, showsBestOfEachSpecies: showsBestOfEachSpecies))
        noteLabel.text = makeNote()
        tableView.reloadData()
        updateEmptyState()
        layOutHeader()
    }

    fileprivate func makeNote() -> String {
        var notes = ["Ranked by \(stat.name) at level \(level.rawValue), from Gen 3 on. Green and red values are raised or lowered by the nature."]
        notes.append("Ones not fully trained in \(stat.shortName) show what EV training would reach, using only the EVs they have left.")
        if (ranking.catchesWithoutIV > 0) {
            notes.append(ranking.catchesWithoutIV == 1 ? "1 catch is left out because its \(stat.name) IV isn't logged." : "\(ranking.catchesWithoutIV) catches are left out because their \(stat.name) IV isn't logged.")
        }
        return notes.joined(separator: " ")
    }

    fileprivate func layOutHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let header = (tableView.tableHeaderView as? BattlersHeaderView) ?? BattlersHeaderView(rankingControl: statControl, levelControl: levelControl, missingIVsButton: hiddenButton, noteLabel: noteLabel)
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard tableView.tableHeaderView !== header || header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    fileprivate func updateEmptyState() {
        guard ranking.leaders.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = EmptyStateView(symbolName: "chart.bar", title: "Nothing to rank", message: "Log IVs on a catch's details to see how its stats compare.")
    }

    @objc fileprivate func statChanged() {
        stat = Stat(rawValue: statControl.selectedSegmentIndex) ?? .speed
        Haptics.tap()
        reloadRanking()
    }

    @objc fileprivate func levelChanged() {
        level = BattleLevel.allCases[levelControl.selectedSegmentIndex]
        Haptics.tap()
        reloadRanking()
    }

    // MARK: Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.leaders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatLeaderCell.reuseIdentifier, for: indexPath) as! StatLeaderCell
        cell.configure(leader: ranking.leaders[indexPath.row], rank: indexPath.row + 1, stat: stat, level: level)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let detail = CatchDetailTVC(container: container, catchId: ranking.leaders[indexPath.row].id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }
}
