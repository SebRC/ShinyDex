import UIKit

class StatsVC: UIViewController {
    fileprivate let scrollView = UIScrollView()
    fileprivate let stack = UIStackView()
    fileprivate let huntRanking = HuntRankingView()
    fileprivate let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        view.backgroundColor = Color.background
        stack.axis = .vertical
        stack.spacing = 6
        huntRanking.onSelect = { [weak self] hunt in
            self?.showCatch(hunt)
        }
        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    fileprivate func reload() {
        for view in stack.arrangedSubviews {
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        let stats = container.getCatchStatistics.handle(GetCatchStatisticsQuery())
        guard stats.foundCount > 0 else {
            let empty = EmptyStateView(symbolName: "chart.bar.fill",
                                       title: "No stats yet",
                                       message: "Log your first shiny and your stats will show up here.")
            stack.addArrangedSubview(empty)
            empty.heightAnchor.constraint(equalToConstant: 420).isActive = true
            return
        }
        addYearInReview(stats)
        addOverview(stats)
        addGoal(stats)
        addEncountersToday(stats)
        addStreaks(stats)
        addYears(stats)
        addFullOddsLuck(stats)
        addLuckiestPeriods(stats)
        addLuckiestDates(stats)
        addRecords(stats)
        addHuntRankings(stats)
        let ballCounts = Dictionary(uniqueKeysWithValues: stats.ballUsage.map { ($0.key, $0.count) })
        addUsageGrid(title: "Balls", noun: "balls", items: BallGrid(container: container).ballNames.map { ball in
            UsageGridItem(title: BallGrid.getDisplayName(of: ball), image: UIImage(named: ball), count: ballCounts[ball] ?? 0, filter: .ball(ball))
        }, total: stats.caughtCount)
        addUsage(title: "Games", rows: stats.gameUsage.prefix(6).map { usage in
            UsageRow(title: usage.key.displayName, image: GamesList.games[usage.key].flatMap { PixelArt.makeCenteredImage(named: $0.coverPokemon) }, count: usage.count, filter: .game(usage.key))
        }, total: stats.caughtCount)
        addUsage(title: "Methods", rows: stats.methodUsage.map { usage in
            UsageRow(title: usage.key.rawValue, image: PixelArt.makeCenteredImage(named: usage.key.rawValue), count: usage.count, filter: .method(usage.key))
        }, total: stats.caughtCount)
        addNatures(stats)
        addIVs(stats)
        addGenders(stats)
    }

    fileprivate func showCollection(filter: CollectionFilter? = nil) {
        navigationController?.pushViewController(CollectionTVC(container: container, filter: filter), animated: true)
    }

    fileprivate func showCatch(_ caught: CatchSummary) {
        guard let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    // MARK: Sections

    fileprivate func addSection(_ title: String, _ content: UIView, footnote: String? = nil) {
        let header = SectionHeaderLabel(text: title, horizontalInset: 4)
        let headerWrapper = UIView()
        headerWrapper.addAutoLayoutSubviews(header)
        header.pinEdges(to: headerWrapper, insets: UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0))
        stack.addArrangedSubview(headerWrapper)
        stack.addArrangedSubview(content)
        if let footnote = footnote {
            let label = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
            label.text = footnote
            let wrapper = UIView()
            wrapper.addAutoLayoutSubviews(label)
            label.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 4))
            stack.addArrangedSubview(wrapper)
        }
    }

    fileprivate func addOverview(_ stats: CatchStatistics) {
        let average = stats.averageEncounters.map { $0.grouped } ?? "–"
        let grid = UIStackView(arrangedSubviews: [
            makeRow(StatTile(caption: "Shinies found", value: stats.foundCount.grouped, isValueEmphasized: true),
                StatTile(caption: "Species caught", value: stats.caughtSpeciesCount.grouped)),
            makeRow(StatTile(caption: "Caught", value: stats.caughtCount.grouped, detail: stats.catchRatePercent.map { "\($0)% catch rate" }) { [weak self] in
                    self?.showCollection()
                },
                StatTile(caption: "Got away", value: stats.failedCount.grouped) { [weak self] in
                    self?.showCollection(filter: .gotAway)
                }),
            makeRow(StatTile(caption: "Encounters", value: stats.totalEncounters.grouped),
                StatTile(caption: "Avg per shiny", value: average))
        ])
        grid.axis = .vertical
        grid.spacing = 10
        let footnote = stats.catchesWithEncounters < stats.foundCount
            ? "Averages use the \(stats.catchesWithEncounters) catches with encounters logged."
            : nil
        addSection("Overview", grid, footnote: footnote)
    }

    fileprivate func addGoal(_ stats: CatchStatistics) {
        let year = stats.currentYear
        guard let goal = stats.goal else {
            let tile = StatTile(caption: "\(year) goal", value: "Not set", detail: "Tap to choose how many shinies to find") { [weak self] in
                self?.editGoal(year: year, target: nil)
            }
            addSection("Yearly goal", tile)
            return
        }
        let card = GoalProgressCard(year: year, goal: goal) { [weak self] in
            self?.editGoal(year: year, target: goal.target)
        }
        addSection("Yearly goal", card, footnote: "Counts every shiny found this year, including ones that got away.")
    }

    fileprivate func editGoal(year: Int, target: Int?) {
        presentTextInput(title: "\(year) goal",
                         message: "How many shinies do you want to find this year? Leave it empty to remove the goal.",
                         text: target.map(String.init),
                         placeholder: "Shinies",
                         keyboardType: .numberPad,
                         isValid: { $0.isEmpty || (Int($0) ?? 0) > 0 }) { [weak self] value in
            guard let self = self else { return }
            self.container.setYearlyGoal.handle(SetYearlyGoalCommand(year: year, target: Int(value)))
            Haptics.playSuccess()
            self.reload()
        }
    }

    fileprivate func addYearInReview(_ stats: CatchStatistics) {
        let year = stats.currentYear
        let tile = StatTile(caption: "Year in review", value: "Your \(year)", detail: "Your year of hunting, card by card", isValueEmphasized: true) { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(YearInReviewVC(container: self.container), animated: true)
        }
        stack.addArrangedSubview(tile)
    }

    fileprivate func addEncountersToday(_ stats: CatchStatistics) {
        let tile = StatTile(caption: "Encounters", value: stats.encountersToday.grouped, detail: "Across all hunts since midnight") { [weak self] in
            self?.showEncounterHistory()
        }
        addSection("Today", tile)
    }

    fileprivate func showEncounterHistory() {
        navigationController?.pushViewController(EncounterHistoryTVC(container: container), animated: true)
    }

    fileprivate func addStreaks(_ stats: CatchStatistics) {
        let row = makeRow(StatTile(caption: "Current", value: stats.streaks.map { $0.current.grouped } ?? "–"),
                          StatTile(caption: "Longest", value: stats.streaks.map { $0.longest.grouped } ?? "–"))
        let footnote = stats.streaks.map { "Encounters across all hunts without a shiny, counted since \(StatsVC.formatDay($0.trackedSince))." }
            ?? "Encounters across all hunts without a shiny, counted from your next encounter on."
        addSection("Dry streaks", row, footnote: footnote)
    }

    fileprivate static func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    fileprivate func makeRow(_ views: UIView...) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views)
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }

    fileprivate func addYears(_ stats: CatchStatistics) {
        guard !stats.years.isEmpty else { return }
        let chart = YearChartView(years: stats.years) { [weak self] year in
            self?.showCollection(filter: .period(.year(year)))
        }
        let undatedNote = stats.undatedCount > 0
            ? " \(stats.undatedCount) \(stats.undatedCount == 1 ? "catch was" : "catches were") logged before catch history and \(stats.undatedCount == 1 ? "has" : "have") no year."
            : ""
        addSection("Average encounters by year", chart, footnote: "Tap a year to see its catches." + undatedNote)
    }

    fileprivate func addFullOddsLuck(_ stats: CatchStatistics) {
        guard let lifetimeLuck = stats.lifetimeLuck else { return }
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.clipsToBounds = true
        let list = UIStackView()
        list.axis = .vertical
        list.addArrangedSubview(LuckRow(title: "Lifetime", luck: lifetimeLuck, isEmphasized: true))
        for yearLuck in stats.yearLuck {
            list.addArrangedSubview(LuckRow(title: String(yearLuck.year), luck: yearLuck.luck) { [weak self] in
                self?.showCollection(filter: .period(.year(yearLuck.year)))
            })
        }
        card.addAutoLayoutSubviews(list)
        list.pinEdges(to: card, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        addSection("Expected vs actual at full odds", card, footnote: "Only full odds (1/\(CatchOdds.fullOdds.grouped)) hunts without a method count, so expected shinies are their encounters divided by \(CatchOdds.fullOdds.grouped).")
    }

    fileprivate func addLuckiestPeriods(_ stats: CatchStatistics) {
        guard stats.months.contains(where: { $0.foundCount > 0 }) else { return }
        let calendar = Calendar.current
        let monthBars = stats.months.map {
            PeriodChartView.Bar(period: .month($0.period), label: calendar.veryShortMonthSymbols[$0.period - 1], name: calendar.monthSymbols[$0.period - 1], foundCount: $0.foundCount)
        }
        addPeriodChart(title: "Luckiest months", bars: monthBars)

        let weekdaysByNumber = Dictionary(uniqueKeysWithValues: stats.weekdays.map { ($0.period, $0.foundCount) })
        let weekdayBars = (0..<7).map { offset -> PeriodChartView.Bar in
            let weekday = (calendar.firstWeekday - 1 + offset) % 7 + 1
            return PeriodChartView.Bar(period: .weekday(weekday), label: calendar.shortWeekdaySymbols[weekday - 1], name: calendar.weekdaySymbols[weekday - 1], foundCount: weekdaysByNumber[weekday] ?? 0)
        }
        addPeriodChart(title: "Luckiest weekdays", bars: weekdayBars)
    }

    fileprivate func addPeriodChart(title: String, bars: [PeriodChartView.Bar]) {
        let chart = PeriodChartView(bars: bars) { [weak self] bar in
            self?.showCollection(filter: .period(bar.period))
        }
        let luckiest = chart.luckiestBars
        let names = ListFormatter.localizedString(byJoining: luckiest.map { $0.name })
        let count = luckiest.first?.foundCount ?? 0
        addSection(title, chart, footnote: "Luckiest: \(names), with \(StatsVC.formatShinies(count)). Tap a bar to see those catches.")
    }

    fileprivate func addLuckiestDates(_ stats: CatchStatistics) {
        guard !stats.luckiestDates.isEmpty else { return }
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.clipsToBounds = true
        let list = UIStackView()
        list.axis = .vertical
        for (index, luckyDate) in stats.luckiestDates.prefix(5).enumerated() {
            let filter = CollectionFilter.period(.date(month: luckyDate.month, day: luckyDate.day))
            let row = LuckyDateRow(rank: index + 1, title: filter.title, count: luckyDate.foundCount)
            row.onTap = { [weak self] in
                self?.showCollection(filter: filter)
            }
            list.addArrangedSubview(row)
        }
        card.addAutoLayoutSubviews(list)
        list.pinEdges(to: card, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        addSection("Luckiest dates", card, footnote: "Dates you've found more than one shiny on, across all years.")
    }

    fileprivate static func formatShinies(_ count: Int) -> String {
        return count == 1 ? "1 shiny" : "\(count.grouped) shinies"
    }

    fileprivate func addRecords(_ stats: CatchStatistics) {
        guard let fastest = stats.shortestHunts.first, let longest = stats.longestHunts.first else { return }
        let records = UIStackView(arrangedSubviews: [
            makeRecordCard(title: "Fastest shiny", caught: fastest, symbol: "hare.fill"),
            makeRecordCard(title: "Longest hunt", caught: longest, symbol: "tortoise.fill")
        ])
        records.distribution = .fillEqually
        records.spacing = 10
        addSection("Records", records)
    }

    fileprivate func makeRecordCard(title: String, caught: CatchSummary, symbol: String) -> UIView {
        let card = RecordCard(title: title, symbol: symbol, caught: caught)
        card.onTap = { [weak self] in
            self?.showCatch(caught)
        }
        return card
    }

    fileprivate func addHuntRankings(_ stats: CatchStatistics) {
        guard stats.longestHunts.count > 1 else { return }
        huntRanking.update(longestHunts: stats.longestHunts, shortestHunts: stats.shortestHunts)
        addSection("Hunt rankings", huntRanking, footnote: "Ranked by encounters, leaving out catches without encounters logged.")
    }

    fileprivate func addUsageGrid(title: String, noun: String, items: [UsageGridItem], total: Int) {
        guard total > 0 else { return }
        let grid = UsageGridView(items: items) { [weak self] filter in
            self?.showCollection(filter: filter)
        }
        let used = items.filter { $0.count > 0 }
        var footnote = "\(used.count) of \(items.count) \(noun) used. Faded ones haven't caught a shiny yet."
        if let mostUsed = used.max(by: { $0.count < $1.count }) {
            let percent = Int((Double(mostUsed.count) / Double(total) * 100).rounded())
            footnote = "Most used: \(mostUsed.title), with \(StatsVC.formatShinies(mostUsed.count)) (\(percent)%). " + footnote
        }
        addSection(title, grid, footnote: footnote)
    }

    fileprivate func addUsage(title: String, rows: [UsageRow], total: Int) {
        guard !rows.isEmpty else { return }
        addSection(title, makeUsageCard(rows: rows, total: total))
    }

    fileprivate func makeUsageCard(rows: [UsageRow], total: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.clipsToBounds = true
        let list = UIStackView()
        list.axis = .vertical
        let maxCount = rows.map { $0.count }.max() ?? 1
        for usage in rows {
            let rowView = UsageRowView(row: usage, maxCount: maxCount, total: total)
            rowView.onTap = { [weak self] in
                self?.showCollection(filter: usage.filter)
            }
            list.addArrangedSubview(rowView)
        }
        card.addAutoLayoutSubviews(list)
        list.pinEdges(to: card, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        return card
    }

    fileprivate func addGenders(_ stats: CatchStatistics) {
        guard stats.caughtCount > 0 else { return }
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 10
        if !stats.genderUsage.isEmpty {
            let counts = Dictionary(uniqueKeysWithValues: stats.genderUsage.map { ($0.key, $0.count) })
            content.addArrangedSubview(GenderRatioView(counts: counts) { [weak self] gender in
                self?.showCollection(filter: .gender(gender))
            })
        }
        if stats.unknownGenderCount > 0 {
            content.addArrangedSubview(StatTile(caption: "No gender logged", value: stats.unknownGenderCount.grouped,
                                                detail: stats.unknownGenderCount == 1 ? "Tap to log it" : "Tap to see them and log their genders") { [weak self] in
                self?.showCollection(filter: .missingGender)
            })
        }
        let footnote = stats.genderUsage.isEmpty ? nil
            : "Species that are always one gender or genderless count as that, even when older catches didn't store it."
        addSection("Genders", content, footnote: footnote)
    }

    fileprivate func addNatures(_ stats: CatchStatistics) {
        guard stats.caughtCount > 0 else { return }
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 10
        var footnote = [String]()
        if let mostCommonCount = stats.natureUsage.first?.count {
            content.addArrangedSubview(NatureChartView(usage: stats.natureUsage) { [weak self] nature in
                self?.showCollection(filter: .nature(nature))
            })
            let mostCommonNames = stats.natureUsage.filter { $0.count == mostCommonCount }.map { $0.key.name }
            footnote.append("Most common: \(ListFormatter.localizedString(byJoining: mostCommonNames)), with \(StatsVC.formatShinies(mostCommonCount)). Tap a nature to see those catches.")
        }
        if stats.unknownNatureCount > 0 {
            content.addArrangedSubview(StatTile(caption: "No nature logged", value: stats.unknownNatureCount.grouped,
                                                detail: stats.unknownNatureCount == 1 ? "Tap to log it" : "Tap to see them and log their natures") { [weak self] in
                self?.showCollection(filter: .missingNature)
            })
        }
        else {
            footnote.append("Every catch has a nature logged.")
        }
        addSection("Natures", content, footnote: footnote.isEmpty ? nil : footnote.joined(separator: " "))
    }

    fileprivate func addIVs(_ stats: CatchStatistics) {
        guard stats.caughtCount > 0 else { return }
        guard stats.missingIVsCount > 0 else {
            addSection("IVs", UIView(), footnote: "Every catch from Gen 3 on has IVs logged.")
            return
        }
        let tile = StatTile(caption: "No IVs logged", value: stats.missingIVsCount.grouped,
                            detail: stats.missingIVsCount == 1 ? "Tap to log them" : "Tap to see them and log their IVs") { [weak self] in
            self?.showCollection(filter: .missingIVs)
        }
        addSection("IVs", tile, footnote: "Gen 1–2 catches are left out, since those games use DVs.")
    }

}
