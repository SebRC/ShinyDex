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
        view.backgroundColor = Color.Grey900
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
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
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
        addOverview(stats)
        addYears(stats)
        addFullOddsLuck(stats)
        addLuckiestPeriods(stats)
        addLuckiestDates(stats)
        addRecords(stats)
        addHuntRankings(stats)
        addUsage(title: "Balls", rows: stats.ballUsage.prefix(8).map { usage in
            UsageRow(title: "\(BallGrid.getDisplayName(of: usage.key)) Ball", image: UIImage(named: usage.key), count: usage.count, filter: .ball(usage.key))
        }, total: stats.caughtCount)
        addUsage(title: "Games", rows: stats.gameUsage.prefix(6).map { usage in
            UsageRow(title: usage.key.displayName, image: GamesList.games[usage.key].flatMap { UIImage(named: $0.coverPokemon) }, count: usage.count, filter: .game(usage.key))
        }, total: stats.caughtCount)
        addUsage(title: "Methods", rows: stats.methodUsage.map { usage in
            UsageRow(title: usage.key.rawValue, image: UIImage(named: usage.key.rawValue), count: usage.count, filter: .method(usage.key))
        }, total: stats.caughtCount)
        addNatures(stats)
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
        let header = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
        header.text = title.uppercased()
        header.accessibilityTraits = .header
        let headerWrapper = UIView()
        headerWrapper.addAutoLayoutSubviews(header)
        header.pinEdges(to: headerWrapper, insets: UIEdgeInsets(top: 18, left: 4, bottom: 0, right: 4))
        stack.addArrangedSubview(headerWrapper)
        stack.addArrangedSubview(content)
        if let footnote = footnote {
            let label = UILabel(fontSize: 12, color: Color.Grey500, lines: 0)
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
            makeRow(StatsVC.makeTile(caption: "Shinies found", value: stats.foundCount.grouped, highlighted: true),
                StatsVC.makeTile(caption: "Species caught", value: stats.caughtSpeciesCount.grouped)),
            makeRow(StatsVC.makeTile(caption: "Caught", value: stats.caughtCount.grouped, detail: stats.catchRatePercent.map { "\($0)% catch rate" }) { [weak self] in
                    self?.showCollection()
                },
                StatsVC.makeTile(caption: "Got away", value: stats.failedCount.grouped) { [weak self] in
                    self?.showCollection(filter: .gotAway)
                }),
            makeRow(StatsVC.makeTile(caption: "Encounters", value: stats.totalEncounters.grouped),
                StatsVC.makeTile(caption: "Avg per shiny", value: average))
        ])
        grid.axis = .vertical
        grid.spacing = 10
        let footnote = stats.catchesWithEncounters < stats.foundCount
            ? "Averages use the \(stats.catchesWithEncounters) catches with encounters logged."
            : nil
        addSection("Overview", grid, footnote: footnote)
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
        card.backgroundColor = Color.Grey800
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
        card.backgroundColor = Color.Grey800
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

    fileprivate func addUsage(title: String, rows: [UsageRow], total: Int) {
        guard !rows.isEmpty else { return }
        let card = UIView()
        card.backgroundColor = Color.Grey800
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
        addSection(title, card)
    }

    fileprivate func addNatures(_ stats: CatchStatistics) {
        guard let mostCommonCount = stats.natureUsage.first?.count else { return }
        let chart = NatureChartView(usage: stats.natureUsage) { [weak self] nature in
            self?.showCollection(filter: .nature(nature))
        }
        let mostCommonNames = stats.natureUsage.filter { $0.count == mostCommonCount }.map { $0.key.name }
        var footnote = "Most common: \(ListFormatter.localizedString(byJoining: mostCommonNames)), with \(StatsVC.formatShinies(mostCommonCount)). Tap a nature to see those catches."
        if stats.unknownNatureCount > 0 {
            footnote += " \(stats.unknownNatureCount) \(stats.unknownNatureCount == 1 ? "catch has" : "catches have") no nature logged and \(stats.unknownNatureCount == 1 ? "is" : "are") left out."
        }
        addSection("Natures", chart, footnote: footnote)
    }

    fileprivate static func makeTile(caption: String, value: String, highlighted: Bool = false, detail: String? = nil, onTap: (() -> Void)? = nil) -> UIView {
        let tile: UIView = onTap.map { TappableTile(onTap: $0) } ?? UIView()
        tile.backgroundColor = Color.Grey800
        tile.layer.cornerRadius = CornerRadius.standard
        tile.isAccessibilityElement = true
        tile.accessibilityLabel = caption
        tile.accessibilityValue = value
        let captionLabel = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
        captionLabel.text = caption.uppercased()
        let valueLabel = UILabel(fontSize: 26, weight: .bold, color: highlighted ? Color.Orange500 : Color.Grey100)
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 26, weight: .bold)
        valueLabel.text = value
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 2
        if let detail = detail {
            let detailLabel = UILabel(fontSize: 12, color: Color.Grey400)
            detailLabel.text = detail
            stack.addArrangedSubview(detailLabel)
            tile.accessibilityValue = "\(value), \(detail)"
        }
        stack.isUserInteractionEnabled = false
        tile.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: tile, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        if (onTap != nil) {
            let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
            chevron.tintColor = Color.Grey500
            tile.addAutoLayoutSubviews(chevron)
            NSLayoutConstraint.activate([
                chevron.topAnchor.constraint(equalTo: tile.topAnchor, constant: 13),
                chevron.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -12)
            ])
            tile.accessibilityTraits = .button
        }
        return tile
    }
}
