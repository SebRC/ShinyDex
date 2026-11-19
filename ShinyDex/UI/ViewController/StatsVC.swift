import UIKit

/// Stats across every catch: an overview, average encounters per year, the balls, games and methods used most,
/// and the fastest and longest hunts.
class StatsVC: UIViewController {
	fileprivate let scrollView = UIScrollView()
	fileprivate let stack = UIStackView()
	fileprivate let catchService = CatchService()
	fileprivate let pokemonService = PokemonService()
	fileprivate var pokemonByNumber = [Int: Pokemon]()

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
		pokemonByNumber = Dictionary(pokemonService.getAll().map { ($0.number, $0) }, uniquingKeysWith: { first, _ in first })
		let stats = CatchStats(catches: catchService.getAllIncludingFailed())
		guard stats.totalShinies > 0 else {
			let empty = EmptyStateView(symbolName: "chart.bar.fill",
									   title: "No stats yet",
									   message: "Log your first shiny and your stats will show up here.")
			stack.addArrangedSubview(empty)
			empty.heightAnchor.constraint(equalToConstant: 420).isActive = true
			return
		}
		addOverview(stats)
		addYears(stats)
		addRecords(stats)
		addUsage(title: "Balls", rows: stats.ballUsage.prefix(8).map { usage in
			let pokeball = Pokeball(ballName: usage.key)
			return UsageRow(title: "\(pokeball.name) Ball", image: pokeball.image, count: usage.count, filter: .ball(usage.key))
		}, total: stats.caughtCount)
		addUsage(title: "Games", rows: stats.gameUsage.prefix(6).map { usage in
			UsageRow(title: usage.key.displayName, image: GamesList.games[usage.key].flatMap { UIImage(named: $0.coverPokemon) }, count: usage.count, filter: .game(usage.key))
		}, total: stats.caughtCount)
		addUsage(title: "Methods", rows: stats.methodUsage.map { usage in
			UsageRow(title: usage.key.rawValue, image: UIImage(named: usage.key.rawValue), count: usage.count, filter: .method(usage.key))
		}, total: stats.caughtCount)
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

	fileprivate func addOverview(_ stats: CatchStats) {
		let average = stats.averageEncounters.map { $0.grouped } ?? "–"
		let grid = UIStackView(arrangedSubviews: [
			row(StatsVC.makeTile(caption: "Shinies found", value: stats.totalShinies.grouped, highlighted: true),
				StatsVC.makeTile(caption: "Species caught", value: stats.speciesCount.grouped)),
			row(StatsVC.makeTile(caption: "Caught", value: stats.caughtCount.grouped, detail: stats.catchRate.map { "\($0)% catch rate" }) { [weak self] in
					self?.navigationController?.pushViewController(CollectionTVC(), animated: true)
				},
				StatsVC.makeTile(caption: "Got away", value: stats.failedCount.grouped) { [weak self] in
					self?.navigationController?.pushViewController(CollectionTVC(filter: .gotAway), animated: true)
				}),
			row(StatsVC.makeTile(caption: "Encounters", value: stats.totalEncounters.grouped),
				StatsVC.makeTile(caption: "Avg per shiny", value: average))
		])
		grid.axis = .vertical
		grid.spacing = 10
		let footnote = stats.catchesWithEncounters < stats.totalShinies
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

	fileprivate func addYears(_ stats: CatchStats) {
		guard !stats.years.isEmpty else { return }
		let chart = YearChartView(years: stats.years)
		let footnote = stats.undatedCount > 0
			? "\(stats.undatedCount) \(stats.undatedCount == 1 ? "catch was" : "catches were") logged before catch history and \(stats.undatedCount == 1 ? "has" : "have") no year."
			: nil
		addSection("Average encounters by year", chart, footnote: footnote)
	}

	fileprivate func addRecords(_ stats: CatchStats) {
		guard let fastest = stats.fastestCatch, let longest = stats.longestCatch else { return }
		let records = UIStackView(arrangedSubviews: [
			recordCard(title: "Fastest shiny", caught: fastest, symbol: "hare.fill"),
			recordCard(title: "Longest hunt", caught: longest, symbol: "tortoise.fill")
		])
		records.distribution = .fillEqually
		records.spacing = 10
		addSection("Records", records)
	}

	fileprivate func recordCard(title: String, caught: Catch, symbol: String) -> UIView {
		let card = RecordCard(title: title, symbol: symbol, pokemon: pokemonByNumber[caught.number], caught: caught)
		card.onTap = { [weak self] in
			guard let self = self, let pokemon = self.pokemonByNumber[caught.number] else { return }
			self.navigationController?.pushViewController(CatchDetailTVC(caught: caught, pokemon: pokemon), animated: true)
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
				self?.navigationController?.pushViewController(CollectionTVC(filter: usage.filter), animated: true)
			}
			list.addArrangedSubview(rowView)
		}
		card.addAutoLayoutSubviews(list)
		list.pinEdges(to: card, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
		addSection(title, card, footnote: "Tap a row to see those catches.")
	}

	/// With `onTap`, the tile is a button with a chevron in the corner, opening the matching list.
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

/// A stats tile that opens a list when tapped.
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

/// Bars for each year's average encounters per shiny, with the year and how many shinies underneath.
/// Scrolls sideways once there are more years than fit.
fileprivate class YearChartView: UIView {
	fileprivate static let barAreaHeight: CGFloat = 140

	init(years: [CatchStats.YearStat]) {
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
			columns.addArrangedSubview(YearChartView.makeColumn(year, maxAverage: maxAverage))
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
			// With few years the bars spread across the card; with many they keep their width and scroll.
			columns.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28)
		])
		columns.distribution = .fillEqually
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeColumn(_ year: CatchStats.YearStat, maxAverage: Int) -> UIView {
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
		countLabel.text = year.shinies == 1 ? "1 shiny" : "\(year.shinies) shinies"
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

fileprivate struct UsageRow {
	let title: String
	let image: UIImage?
	let count: Int
	let filter: CollectionFilter
}

/// An icon, a name, a bar sized against the most used entry, and the count with its share of all catches.
/// Tapping it opens the collection filtered to those catches.
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

/// A record (fastest shiny, longest hunt): the Pokémon, how many encounters it took, and when. Tapping opens the catch.
fileprivate class RecordCard: UIControl {
	var onTap: (() -> Void)?

	init(title: String, symbol: String, pokemon: Pokemon?, caught: Catch) {
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

		let sprite = UIImageView(image: pokemon.flatMap { UIImage(named: $0.name.lowercased()) })
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest
		let encountersLabel = UILabel(fontSize: 22, weight: .bold, color: Color.Grey100)
		encountersLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
		encountersLabel.text = caught.encounters.grouped
		encountersLabel.adjustsFontSizeToFitWidth = true
		encountersLabel.minimumScaleFactor = 0.6
		let detailLabel = UILabel(fontSize: 12, color: Color.Grey400)
		detailLabel.text = [pokemon?.name, caught.isFailed ? "got away" : nil, caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
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
		accessibilityLabel = "\(title): \(pokemon?.name ?? "Unknown"), \(caught.encounters) encounters"
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
