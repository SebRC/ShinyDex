import UIKit

final class BattlersTVC: UITableViewController {
    fileprivate let container: AppContainer
    fileprivate let rankingControl = UISegmentedControl(items: BattlerRanking.allCases.map { $0.title })
    fileprivate let levelControl = UISegmentedControl(items: BattleLevel.allCases.map { "Lv. \($0.rawValue)" })
    fileprivate let missingDataLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let missingIVsButton = UIButton(type: .system)
    fileprivate var rankings = BattlerRankings(battlers: [], catchesWithoutIVs: 0, olderGenerationCatches: 0)
    fileprivate var ranking = BattlerRanking.relevantIVs
    fileprivate var level = BattleLevel.fifty
    fileprivate var showsBestOfEachSpecies = false
    fileprivate var countsUnusedStatFully = false

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Battlers"
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.register(BattlerCell.self, forCellReuseIdentifier: BattlerCell.reuseIdentifier)
        setUpControls()
        updateOptionsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadRankings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layOutHeader()
    }

    fileprivate func setUpControls() {
        for control in [rankingControl, levelControl] {
            control.selectedSegmentTintColor = Color.accent
            control.backgroundColor = Color.surfaceRaised
            control.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.footnote, weight: .semibold)], for: .normal)
            control.setTitleTextAttributes([.foregroundColor: Color.onAccent, .font: UIFont.make(.footnote, weight: .bold)], for: .selected)
        }
        var missingIVsConfiguration = UIButton.Configuration.plain()
        missingIVsConfiguration.image = UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold)
        missingIVsConfiguration.imagePlacement = .trailing
        missingIVsConfiguration.imagePadding = Spacing.extraSmall
        missingIVsConfiguration.contentInsets = .zero
        missingIVsConfiguration.baseForegroundColor = Color.accent
        missingIVsButton.configuration = missingIVsConfiguration
        missingIVsButton.contentHorizontalAlignment = .leading
        missingIVsButton.accessibilityHint = "Shows the catches so you can log their IVs."
        missingIVsButton.addTarget(self, action: #selector(missingIVsPressed), for: .touchUpInside)
        rankingControl.selectedSegmentIndex = ranking.rawValue
        rankingControl.accessibilityLabel = "Ranking"
        rankingControl.addTarget(self, action: #selector(rankingChanged), for: .valueChanged)
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
            self.reloadRankings()
        }
        let countsUnusedStat = UIAction(title: "Count Unused Attack Fully", subtitle: "For the Stats ranking", image: UIImage(systemName: "equal.circle"),
                                        state: countsUnusedStatFully ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.countsUnusedStatFully.toggle()
            Haptics.tap()
            self.updateOptionsButton()
            self.reloadRankings()
        }
        let optionsButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: UIMenu(children: [bestOfEachSpecies, countsUnusedStat]))
        optionsButton.accessibilityLabel = "Options"
        let statRankingButton = UIBarButtonItem(image: UIImage(systemName: "chart.bar.xaxis"), style: .plain, target: self, action: #selector(statRankingPressed))
        statRankingButton.accessibilityLabel = "Rank by stat"
        let teamsButton = UIBarButtonItem(image: UIImage(systemName: "person.3"), style: .plain, target: self, action: #selector(teamsPressed))
        teamsButton.accessibilityLabel = "Teams"
        navigationItem.rightBarButtonItems = [optionsButton, statRankingButton, teamsButton]
    }

    // MARK: Data

    fileprivate func reloadRankings() {
        rankings = container.rankBattlers.handle(RankBattlersQuery(ranking: ranking, level: level, showsBestOfEachSpecies: showsBestOfEachSpecies,
                                                                       countsUnusedStatFully: countsUnusedStatFully))
        missingDataLabel.text = makeMissingDataText()
        refreshMissingIVsButton()
        tableView.reloadData()
        updateEmptyState()
        layOutHeader()
    }

    fileprivate func makeMissingDataText() -> String? {
        var notes = [String]()
        if (rankings.olderGenerationCatches > 0) {
            notes.append("Gen 1–2 catches aren't ranked, since they use DVs.")
        }
        guard ranking == .combinedStats else {
            notes.append("The attacking stat a Pokémon doesn't use counts for less.")
            return notes.joined(separator: " ")
        }
        notes.append(countsUnusedStatFully ? "Every stat counts fully." : "The attacking stat a Pokémon doesn't use counts a quarter.")
        if (rankings.battlers.contains { $0.combinedStats?.isEstimated == true }) {
            notes.append("≈ assumes an average IV where one isn't logged.")
        }
        return notes.joined(separator: " ")
    }

    fileprivate func refreshMissingIVsButton() {
        let count = rankings.catchesWithoutIVs
        missingIVsButton.isHidden = count == 0
        let title = count == 1 ? "1 catch has no IVs logged" : "\(count) catches have no IVs logged"
        missingIVsButton.configuration?.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.make(.footnote, weight: .semibold)]))
        missingIVsButton.accessibilityLabel = title
    }

    @objc fileprivate func statRankingPressed() {
        navigationController?.pushViewController(StatRankingTVC(container: container, level: level), animated: true)
    }

    @objc fileprivate func teamsPressed() {
        navigationController?.pushViewController(TeamsTVC(container: container), animated: true)
    }

    @objc fileprivate func missingIVsPressed() {
        navigationController?.pushViewController(CollectionTVC(container: container, filter: .missingIVs), animated: true)
    }

    fileprivate func layOutHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let header = (tableView.tableHeaderView as? BattlersHeaderView) ?? BattlersHeaderView(rankingControl: rankingControl, levelControl: levelControl, missingIVsButton: missingIVsButton, noteLabel: missingDataLabel)
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard tableView.tableHeaderView !== header || header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    fileprivate func updateEmptyState() {
        guard rankings.battlers.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = EmptyStateView(symbolName: "trophy", title: "No battlers yet", message: "Log IVs on a catch's details to see how it ranks for battle.")
    }

    @objc fileprivate func rankingChanged() {
        ranking = BattlerRanking(rawValue: rankingControl.selectedSegmentIndex) ?? .relevantIVs
        Haptics.tap()
        reloadRankings()
    }

    @objc fileprivate func levelChanged() {
        level = BattleLevel.allCases[levelControl.selectedSegmentIndex]
        Haptics.tap()
        reloadRankings()
    }

    // MARK: Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankings.battlers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BattlerCell.reuseIdentifier, for: indexPath) as! BattlerCell
        let battler = rankings.battlers[indexPath.row]
        cell.configure(battler: battler, rank: indexPath.row + 1, ranking: ranking, level: level)
        cell.onReadinessPressed = { [weak self] in self?.showReadiness(of: battler) }
        return cell
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let battler = rankings.battlers[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "Readiness Breakdown", image: UIImage(systemName: "chart.bar.doc.horizontal")) { _ in self?.showReadiness(of: battler) },
                UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in self?.showDetails(of: battler) }
            ])
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDetails(of: rankings.battlers[indexPath.row])
    }

    fileprivate func showDetails(of battler: BattlerSummary) {
        guard let detail = CatchDetailTVC(container: container, catchId: battler.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    fileprivate func showReadiness(of battler: BattlerSummary) {
        navigationController?.pushViewController(BattleReadinessVC(container: container, battler: battler, level: level), animated: true)
    }
}

final class BattlersHeaderView: UIView {
    init(rankingControl: UISegmentedControl, levelControl: UISegmentedControl, missingIVsButton: UIButton, noteLabel: UILabel) {
        super.init(frame: .zero)
        let levelCaption = UILabel(style: .footnote, weight: .semibold, color: Color.textSecondary)
        levelCaption.text = "Stats at"
        let levelRow = UIStackView(arrangedSubviews: [levelCaption, levelControl])
        levelRow.spacing = Spacing.small
        levelRow.alignment = .center
        let notes = UIStackView(arrangedSubviews: [missingIVsButton, noteLabel])
        notes.axis = .vertical
        notes.spacing = Spacing.extraSmall
        let layout = UIStackView(arrangedSubviews: [rankingControl, levelRow, notes])
        layout.axis = .vertical
        layout.spacing = Spacing.medium
        layout.alignment = .fill
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.screenMargin, bottom: Spacing.small, right: Spacing.screenMargin))
        NSLayoutConstraint.activate([
            rankingControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
            levelControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
