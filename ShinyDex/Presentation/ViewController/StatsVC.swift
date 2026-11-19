import UIKit

class StatsVC: UIViewController {
	fileprivate let scrollView = UIScrollView()
	fileprivate let stack = UIStackView()
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
		addLuckiestPeriods(stats)
		addLuckiestDates(stats)
		addRecords(stats)
		addUsage(title: "Balls", rows: stats.ballUsage.prefix(8).map { usage in
			UsageRow(title: "\(BallGrid.displayName(of: usage.key)) Ball", image: UIImage(named: usage.key), count: usage.count, filter: .ball(usage.key))
		}, total: stats.caughtCount)
		addUsage(title: "Games", rows: stats.gameUsage.prefix(6).map { usage in
			UsageRow(title: usage.key.displayName, image: GamesList.games[usage.key].flatMap { UIImage(named: $0.coverPokemon) }, count: usage.count, filter: .game(usage.key))
		}, total: stats.caughtCount)
		addUsage(title: "Methods", rows: stats.methodUsage.map { usage in
			UsageRow(title: usage.key.rawValue, image: UIImage(named: usage.key.rawValue), count: usage.count, filter: .method(usage.key))
		}, total: stats.caughtCount)
	}

	fileprivate func showCollection(filter: CollectionFilter? = nil) {
		navigationController?.pushViewController(CollectionTVC(container: container, filter: filter), animated: true)
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
			row(StatsVC.makeTile(caption: "Shinies found", value: stats.foundCount.grouped, highlighted: true),
				StatsVC.makeTile(caption: "Species caught", value: stats.caughtSpeciesCount.grouped)),
			row(StatsVC.makeTile(caption: "Caught", value: stats.caughtCount.grouped, detail: stats.catchRatePercent.map { "\($0)% catch rate" }) { [weak self] in
					self?.showCollection()
				},
				StatsVC.makeTile(caption: "Got away", value: stats.failedCount.grouped) { [weak self] in
					self?.showCollection(filter: .gotAway)
				}),
			row(StatsVC.makeTile(caption: "Encounters", value: stats.totalEncounters.grouped),
				StatsVC.makeTile(caption: "Avg per shiny", value: average))
		])
		grid.axis = .vertical
		grid.spacing = 10
		let footnote = stats.catchesWithEncounters < stats.foundCount
			? "Averages use the \(stats.catchesWithEncounters) catches with encounters logged."
			: nil
		addSection("Overview", grid, footnote: footnote)
	}

	fileprivate func row(_ views: UIView...) -> UIStackView {
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
		addSection(title, chart, footnote: "Luckiest: \(names), with \(StatsVC.shinies(count)). Tap a bar to see those catches.")
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
		addSection("Luckiest dates", card, footnote: "Dates you've found more than one shiny on, across all years. Tap one to see those catches.")
	}

	fileprivate static func shinies(_ count: Int) -> String {
		return count == 1 ? "1 shiny" : "\(count.grouped) shinies"
	}

	fileprivate func addRecords(_ stats: CatchStatistics) {
		guard let fastest = stats.fastestCatch, let longest = stats.longestCatch else { return }
		let records = UIStackView(arrangedSubviews: [
			recordCard(title: "Fastest shiny", caught: fastest, symbol: "hare.fill"),
			recordCard(title: "Longest hunt", caught: longest, symbol: "tortoise.fill")
		])
		records.distribution = .fillEqually
		records.spacing = 10
		addSection("Records", records)
	}

	fileprivate func recordCard(title: String, caught: CatchSummary, symbol: String) -> UIView {
		let card = RecordCard(title: title, symbol: symbol, caught: caught)
		card.onTap = { [weak self] in
			guard let self = self, let detail = CatchDetailTVC(container: self.container, catchId: caught.id) else { return }
			self.navigationController?.pushViewController(detail, animated: true)
		}
		return card
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
		addSection(title, card, footnote: "Tap a row to see those catches.")
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
			let chevron = UIImageView(image: UIImage.symbol("chevron.right", pointSize: 12, weight: .semibold))
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

fileprivate class TappableTile: UIControl {
	fileprivate let onTap: () -> Void

	init(onTap: @escaping () -> Void) {
		self.onTap = onTap
		super.init(frame: .zero)
		addTarget(self, action: #selector(tapped), for: .touchUpInside)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Color.Grey700 : Color.Grey800
		}
	}

	@objc fileprivate func tapped() {
		onTap()
	}
}

fileprivate class TappableColumn: UIControl {
	fileprivate let onTap: () -> Void

	init(content: UIView, onTap: @escaping () -> Void) {
		self.onTap = onTap
		super.init(frame: .zero)
		layer.cornerRadius = 8
		content.isUserInteractionEnabled = false
		content.isAccessibilityElement = false
		addAutoLayoutSubviews(content)
		content.pinEdges(to: self)
		addTarget(self, action: #selector(tapped), for: .touchUpInside)
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityLabel = content.accessibilityLabel
		accessibilityHint = "Shows these catches."
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Color.Grey700 : .clear
		}
	}

	@objc fileprivate func tapped() {
		onTap()
	}
}

fileprivate class YearChartView: UIView {
	fileprivate static let barAreaHeight: CGFloat = 140

	init(years: [CatchStatistics.Year], onSelectYear: @escaping (Int) -> Void) {
		super.init(frame: .zero)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard

		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		let columns = UIStackView()
		columns.alignment = .bottom
		columns.spacing = 14
		let maxAverage = max(1, years.compactMap { $0.averageEncounters }.max() ?? 1)
		for year in years {
			columns.addArrangedSubview(TappableColumn(content: YearChartView.makeColumn(year, maxAverage: maxAverage)) {
				onSelectYear(year.year)
			})
		}
		addAutoLayoutSubviews(scrollView)
		scrollView.addAutoLayoutSubviews(columns)
		scrollView.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 0, bottom: 12, right: 0))
		NSLayoutConstraint.activate([
			columns.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			columns.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			columns.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 14),
			columns.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -14),
			columns.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
			columns.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28)
		])
		columns.distribution = .fillEqually
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeColumn(_ year: CatchStatistics.Year, maxAverage: Int) -> UIView {
		let valueLabel = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey200)
		valueLabel.text = year.averageEncounters.map { $0.grouped } ?? "–"
		valueLabel.textAlignment = .center
		valueLabel.adjustsFontSizeToFitWidth = true
		valueLabel.minimumScaleFactor = 0.7

		let bar = UIView()
		bar.backgroundColor = year.averageEncounters == nil ? Color.Grey700 : Color.Orange500
		bar.layer.cornerRadius = 6
		bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		let barArea = UIView()
		barArea.addAutoLayoutSubviews(bar)
		let fraction = CGFloat(year.averageEncounters ?? 0) / CGFloat(maxAverage)
		NSLayoutConstraint.activate([
			barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
			bar.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
			bar.centerXAnchor.constraint(equalTo: barArea.centerXAnchor),
			bar.widthAnchor.constraint(equalToConstant: 28),
			bar.heightAnchor.constraint(equalToConstant: max(4, barAreaHeight * fraction))
		])

		let yearLabel = UILabel(fontSize: 13, weight: .semibold)
		yearLabel.text = String(year.year)
		yearLabel.textAlignment = .center
		let countLabel = UILabel(fontSize: 11, color: Color.Grey400)
		countLabel.text = year.foundCount == 1 ? "1 shiny" : "\(year.foundCount) shinies"
		countLabel.textAlignment = .center

		let column = UIStackView(arrangedSubviews: [valueLabel, barArea, yearLabel, countLabel])
		column.axis = .vertical
		column.spacing = 4
		column.widthAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
		column.isAccessibilityElement = true
		column.accessibilityLabel = "\(year.year): \(countLabel.text ?? ""), " + (year.averageEncounters.map { "average \($0) encounters" } ?? "no encounters logged")
		return column
	}
}

fileprivate class PeriodChartView: UIView {
	struct Bar {
		let period: CatchPeriod
		let label: String
		let name: String
		let foundCount: Int
	}

	fileprivate static let barAreaHeight: CGFloat = 90
	let luckiestBars: [Bar]

	init(bars: [Bar], onSelect: @escaping (Bar) -> Void) {
		let maxCount = bars.map { $0.foundCount }.max() ?? 0
		luckiestBars = maxCount > 0 ? bars.filter { $0.foundCount == maxCount } : []
		super.init(frame: .zero)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard

		let columns = UIStackView(arrangedSubviews: bars.map { bar -> UIView in
			let column = PeriodChartView.makeColumn(bar, maxCount: max(1, maxCount))
			guard bar.foundCount > 0 else { return column }
			return TappableColumn(content: column) { onSelect(bar) }
		})
		columns.alignment = .bottom
		columns.distribution = .fillEqually
		columns.spacing = 4
		addAutoLayoutSubviews(columns)
		columns.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 10, bottom: 10, right: 10))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeColumn(_ bar: Bar, maxCount: Int) -> UIView {
		let isLuckiest = bar.foundCount == maxCount
		let countLabel = UILabel(fontSize: 11, weight: .semibold, color: isLuckiest ? Color.Grey100 : Color.Grey400)
		countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
		countLabel.text = bar.foundCount > 0 ? String(bar.foundCount) : " "
		countLabel.textAlignment = .center
		countLabel.adjustsFontSizeToFitWidth = true
		countLabel.minimumScaleFactor = 0.6

		let barView = UIView()
		barView.backgroundColor = bar.foundCount == 0 ? Color.Grey700 : isLuckiest ? Color.Orange500 : Color.Orange800
		barView.layer.cornerRadius = 4
		barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		let barArea = UIView()
		barArea.addAutoLayoutSubviews(barView)
		let fraction = CGFloat(bar.foundCount) / CGFloat(maxCount)
		NSLayoutConstraint.activate([
			barArea.heightAnchor.constraint(equalToConstant: barAreaHeight),
			barView.bottomAnchor.constraint(equalTo: barArea.bottomAnchor),
			barView.centerXAnchor.constraint(equalTo: barArea.centerXAnchor),
			barView.widthAnchor.constraint(equalTo: barArea.widthAnchor, multiplier: 0.7),
			barView.heightAnchor.constraint(equalToConstant: max(3, barAreaHeight * fraction))
		])

		let label = UILabel(fontSize: 11, weight: .semibold, color: isLuckiest ? Color.Orange500 : Color.Grey400)
		label.text = bar.label
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.7

		let column = UIStackView(arrangedSubviews: [countLabel, barArea, label])
		column.axis = .vertical
		column.spacing = 4
		column.isAccessibilityElement = true
		column.accessibilityLabel = "\(bar.name): \(bar.foundCount == 1 ? "1 shiny" : "\(bar.foundCount) shinies")"
		return column
	}
}

fileprivate class LuckyDateRow: UIControl {
	var onTap: (() -> Void)?

	init(rank: Int, title: String, count: Int) {
		super.init(frame: .zero)
		let rankLabel = UILabel(fontSize: 13, weight: .bold, color: rank == 1 ? Color.Orange500 : Color.Grey500)
		rankLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
		rankLabel.text = "#\(rank)"
		rankLabel.setContentHuggingPriority(.required, for: .horizontal)
		let titleLabel = UILabel(fontSize: 15, weight: .medium)
		titleLabel.text = title
		let countLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey300)
		countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
		countLabel.text = "\(count) shinies"
		countLabel.setContentHuggingPriority(.required, for: .horizontal)
		countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		let chevron = UIImageView(image: UIImage.symbol("chevron.right", pointSize: 12, weight: .semibold))
		chevron.tintColor = Color.Grey500
		chevron.setContentHuggingPriority(.required, for: .horizontal)
		let layout = UIStackView(arrangedSubviews: [rankLabel, titleLabel, countLabel, chevron])
		layout.alignment = .center
		layout.spacing = 10
		layout.isUserInteractionEnabled = false
		addAutoLayoutSubviews(layout)
		layout.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 12))
		rankLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
		addTarget(self, action: #selector(tapped), for: .touchUpInside)
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityLabel = "Number \(rank): \(title), \(count) shinies"
		accessibilityHint = "Shows the catches from this date."
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Color.Grey700 : .clear
		}
	}

	@objc fileprivate func tapped() {
		onTap?()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate struct UsageRow {
	let title: String
	let image: UIImage?
	let count: Int
	let filter: CollectionFilter
}

fileprivate class UsageRowView: UIControl {
	var onTap: (() -> Void)?

	init(row: UsageRow, maxCount: Int, total: Int) {
		super.init(frame: .zero)
		let icon = UIImageView(image: row.image)
		icon.contentMode = .scaleAspectFit
		icon.layer.magnificationFilter = .nearest
		let titleLabel = UILabel(fontSize: 15, weight: .medium)
		titleLabel.text = row.title
		let countLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey300)
		countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
		let percent = total > 0 ? Int((Double(row.count) / Double(total) * 100).rounded()) : 0
		countLabel.text = "\(row.count) · \(percent)%"
		countLabel.setContentHuggingPriority(.required, for: .horizontal)
		countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		let track = UIView()
		track.backgroundColor = Color.Grey700
		track.layer.cornerRadius = 3
		let fill = UIView()
		fill.backgroundColor = Color.Orange500
		fill.layer.cornerRadius = 3
		track.addAutoLayoutSubviews(fill)

		let titleRow = UIStackView(arrangedSubviews: [titleLabel, countLabel])
		titleRow.spacing = 8
		let labels = UIStackView(arrangedSubviews: [titleRow, track])
		labels.axis = .vertical
		labels.spacing = 6
		let chevron = UIImageView(image: UIImage.symbol("chevron.right", pointSize: 12, weight: .semibold))
		chevron.tintColor = Color.Grey500
		chevron.setContentHuggingPriority(.required, for: .horizontal)
		let layout = UIStackView(arrangedSubviews: [icon, labels, chevron])
		layout.alignment = .center
		layout.spacing = 10
		layout.isUserInteractionEnabled = false
		addAutoLayoutSubviews(layout)
		layout.pinEdges(to: self, insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
		addTarget(self, action: #selector(tapped), for: .touchUpInside)
		NSLayoutConstraint.activate([
			icon.widthAnchor.constraint(equalToConstant: 34),
			icon.heightAnchor.constraint(equalToConstant: 34),
			track.heightAnchor.constraint(equalToConstant: 6),
			fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
			fill.topAnchor.constraint(equalTo: track.topAnchor),
			fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
			fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(row.count) / CGFloat(max(1, maxCount)))
		])
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityLabel = "\(row.title), \(row.count) \(row.count == 1 ? "catch" : "catches"), \(percent) percent"
		accessibilityHint = "Shows these catches in your collection."
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Color.Grey700 : .clear
		}
	}

	@objc fileprivate func tapped() {
		onTap?()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate class RecordCard: UIControl {
	var onTap: (() -> Void)?

	init(title: String, symbol: String, caught: CatchSummary) {
		super.init(frame: .zero)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard

		let symbolView = UIImageView(image: UIImage.symbol(symbol, pointSize: 12, weight: .bold))
		symbolView.tintColor = Color.Orange500
		let titleLabel = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
		titleLabel.text = title.uppercased()
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.minimumScaleFactor = 0.8
		let titleRow = UIStackView(arrangedSubviews: [symbolView, titleLabel])
		titleRow.spacing = 5
		titleRow.alignment = .center

		let sprite = UIImageView(image: UIImage(named: caught.pokemonName.lowercased()))
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest
		let encountersLabel = UILabel(fontSize: 22, weight: .bold, color: Color.Grey100)
		encountersLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
		encountersLabel.text = caught.encounters.grouped
		encountersLabel.adjustsFontSizeToFitWidth = true
		encountersLabel.minimumScaleFactor = 0.6
		let detailLabel = UILabel(fontSize: 12, color: Color.Grey400)
		detailLabel.text = [caught.pokemonName, caught.isFailed ? "got away" : nil, caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
		detailLabel.adjustsFontSizeToFitWidth = true
		detailLabel.minimumScaleFactor = 0.8

		let stack = UIStackView(arrangedSubviews: [titleRow, sprite, encountersLabel, detailLabel])
		stack.axis = .vertical
		stack.alignment = .leading
		stack.spacing = 2
		stack.setCustomSpacing(-4, after: sprite)
		stack.isUserInteractionEnabled = false
		addAutoLayoutSubviews(stack)
		stack.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
		NSLayoutConstraint.activate([
			sprite.widthAnchor.constraint(equalToConstant: 64),
			sprite.heightAnchor.constraint(equalToConstant: 64)
		])
		addTarget(self, action: #selector(tapped), for: .touchUpInside)
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityLabel = "\(title): \(caught.pokemonName), \(caught.encounters) encounters"
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Color.Grey700 : Color.Grey800
		}
	}

	@objc fileprivate func tapped() {
		onTap?()
	}
}
