import UIKit

enum CollectionFilter {
	case ball(String)
	case game(Games)
	case method(HuntMethod)
	case gotAway
	case period(CatchPeriod)

	var showsFailed: Bool {
		switch self {
		case .gotAway, .period: return true
		case .ball, .game, .method: return false
		}
	}

	var isGotAway: Bool {
		if case .gotAway = self { return true }
		return false
	}

	var title: String {
		switch self {
		case .ball(let ball): return "\(ball.capitalizingFirstLetter()) Ball"
		case .game(let game): return game.displayName
		case .method(let method): return method.rawValue
		case .gotAway: return "Got away"
		case .period(let period): return CollectionFilter.getTitle(of: period)
		}
	}

	fileprivate static func getTitle(of period: CatchPeriod) -> String {
		let calendar = Calendar.current
		switch period {
		case .year(let year):
			return String(year)
		case .month(let month):
			return calendar.monthSymbols[month - 1]
		case .weekday(let weekday):
			return calendar.weekdaySymbols[weekday - 1]
		case let .date(month, day):
			let anyLeapYear = 2024
			guard let date = calendar.date(from: DateComponents(year: anyLeapYear, month: month, day: day)) else { return "\(day)/\(month)" }
			let formatter = DateFormatter()
			formatter.setLocalizedDateFormatFromTemplate("MMMMd")
			return formatter.string(from: date)
		}
	}

	func matches(_ caught: CatchSummary) -> Bool {
		switch self {
		case .ball(let ball): return caught.caughtBall == ball
		case .game(let game): return caught.game == game
		case .method(let method): return caught.huntMethod == method
		case .gotAway: return caught.isFailed
		case .period(let period): return caught.caughtDate.map { period.contains($0, calendar: .current) } ?? false
		}
	}
}

class CollectionTVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating {
	fileprivate typealias Entry = CatchSummary

	fileprivate enum SortOrder: Int {
		case dex
		case recent
	}

	fileprivate static let headerKind = "collectionHeader"

	fileprivate let container: AppContainer
	fileprivate let searchController = UISearchController(searchResultsController: nil)
	fileprivate var collectionView: UICollectionView!
	fileprivate var entries = [Entry]()
	fileprivate var visibleEntries = [Entry]()
	fileprivate var sortOrder = SortOrder.dex
	fileprivate let filter: CollectionFilter?

	init(container: AppContainer, filter: CollectionFilter? = nil) {
		self.container = container
		self.filter = filter
		if case .period? = filter {
			sortOrder = .recent
		}
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = filter?.title ?? "Collection"
		view.backgroundColor = Color.Grey900
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceVertical = true
		collectionView.keyboardDismissMode = .onDrag
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(CollectionCard.self, forCellWithReuseIdentifier: CollectionCard.reuseIdentifier)
		collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: CollectionTVC.headerKind, withReuseIdentifier: CollectionHeader.reuseIdentifier)
		view.addAutoLayoutSubviews(collectionView)
		collectionView.pinEdges(to: view)
		setUpSearchController()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadEntries()
	}

	fileprivate func setUpSearchController() {
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search catches"
		navigationItem.searchController = searchController
		definesPresentationContext = true
	}

	fileprivate func makeLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0), heightDimension: .estimated(170))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(170))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 10
		section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 11, bottom: 24, trailing: 11)
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: CollectionTVC.headerKind, alignment: .top)
		header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
		section.boundarySupplementaryItems = [header]
		return UICollectionViewCompositionalLayout(section: section)
	}

	// MARK: Data

	fileprivate func reloadEntries() {
		let source = container.getCatches.handle(GetCatchesQuery(scope: .collection, includingFailed: filter?.showsFailed == true))
		entries = source.filter { filter?.matches($0) ?? true }
		applySearch()
	}

	fileprivate func applySearch() {
		let searchText = searchController.searchBar.text?.lowercased() ?? ""
		var shown = searchText.isEmpty ? entries : entries.filter { [$0.pokemonName, $0.nickname].compactMap { $0?.lowercased() }.contains { $0.contains(searchText) } }
		if (sortOrder == .recent) {
			shown = shown.enumerated().sorted { lhs, rhs in
				switch (lhs.element.caughtDate, rhs.element.caughtDate) {
				case let (l?, r?): return l != r ? l > r : lhs.offset < rhs.offset
				case (_?, nil): return true
				case (nil, _?): return false
				case (nil, nil): return lhs.offset < rhs.offset
				}
			}.map { $0.element }
		}
		visibleEntries = shown
		collectionView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		guard visibleEntries.isEmpty else {
			collectionView.backgroundView = nil
			return
		}
		let emptyMessage = filter?.isGotAway == true
			? "Shinies you log as got away will show up here."
			: filter.map { "No catches in \($0.title) any more." }
			?? "Log a catch with the sparkles button next to a Pokémon in the Pokédex or on its tracker."
		collectionView.backgroundView = entries.isEmpty
			? EmptyStateView(symbolName: "sparkles",
							 title: filter?.isGotAway == true ? "None got away" : (filter == nil ? "No shinies yet" : "Nothing here"),
							 message: emptyMessage)
			: EmptyStateView(symbolName: "magnifyingglass",
							 title: "No results",
							 message: "No catches match \u{201C}\(searchController.searchBar.text ?? "")\u{201D}.")
	}

	func updateSearchResults(for searchController: UISearchController) {
		applySearch()
	}

	// MARK: Collection view

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return visibleEntries.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCard.reuseIdentifier, for: indexPath) as! CollectionCard
		let entry = visibleEntries[indexPath.item]
		cell.configure(caught: entry)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.reuseIdentifier, for: indexPath) as! CollectionHeader
		let catches = entries
		header.configure(shiniesCaption: filter?.isGotAway == true ? "GOT AWAY" : "SHINIES",
						 shinies: catches.count,
						 species: Set(catches.map { $0.number }).count,
						 encounters: catches.reduce(0) { $0 + $1.encounters },
						 sortIndex: sortOrder.rawValue)
		header.isHidden = entries.isEmpty
		header.onSortChanged = { [weak self] index in
			guard let self = self else { return }
			self.sortOrder = SortOrder(rawValue: index) ?? .dex
			Haptics.tap()
			self.applySearch()
		}
		return header
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let entry = visibleEntries[indexPath.item]
		guard let detail = CatchDetailTVC(container: container, catchId: entry.id) else { return }
		navigationController?.pushViewController(detail, animated: true)
	}
}

fileprivate class CollectionHeader: UICollectionReusableView {
	static let reuseIdentifier = "collectionHeader"

	var onSortChanged: ((Int) -> Void)?

	fileprivate let shiniesValue = UILabel(fontSize: 22, weight: .bold, color: Color.Orange500)
	fileprivate let speciesValue = UILabel(fontSize: 22, weight: .bold, color: Color.Grey100)
	fileprivate let encountersValue = UILabel(fontSize: 22, weight: .bold, color: Color.Grey100)
	fileprivate let sortControl = UISegmentedControl(items: ["Dex order", "Recent"])

	override init(frame: CGRect) {
		super.init(frame: frame)
		let tiles = UIStackView(arrangedSubviews: [
			CollectionHeader.makeTile(caption: "SHINIES", value: shiniesValue),
			CollectionHeader.makeTile(caption: "SPECIES", value: speciesValue),
			CollectionHeader.makeTile(caption: "ENCOUNTERS", value: encountersValue)
		])
		tiles.distribution = .fillEqually
		tiles.spacing = 10

		sortControl.selectedSegmentTintColor = Color.Orange500
		sortControl.backgroundColor = Color.Grey800
		sortControl.setTitleTextAttributes([.foregroundColor: Color.Grey900, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
		sortControl.setTitleTextAttributes([.foregroundColor: Color.Grey300, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
		sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)

		let stack = UIStackView(arrangedSubviews: [tiles, sortControl])
		stack.axis = .vertical
		stack.spacing = 12
		addAutoLayoutSubviews(stack)
		stack.pinEdges(to: self, insets: UIEdgeInsets(top: 4, left: 0, bottom: 10, right: 0))
		sortControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeTile(caption: String, value: UILabel) -> UIView {
		let tile = UIView()
		tile.backgroundColor = Color.Grey800
		tile.layer.cornerRadius = CornerRadius.standard
		tile.isAccessibilityElement = true
		tile.accessibilityLabel = caption.capitalized
		let captionLabel = UILabel(fontSize: 11, weight: .semibold, color: Color.Grey400)
		captionLabel.text = caption
		captionLabel.adjustsFontSizeToFitWidth = true
		captionLabel.minimumScaleFactor = 0.8
		value.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
		value.adjustsFontSizeToFitWidth = true
		value.minimumScaleFactor = 0.6
		let stack = UIStackView(arrangedSubviews: [captionLabel, value])
		stack.axis = .vertical
		stack.spacing = 2
		tile.addAutoLayoutSubviews(stack)
		stack.pinEdges(to: tile, insets: UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
		return tile
	}

	func configure(shiniesCaption: String, shinies: Int, species: Int, encounters: Int, sortIndex: Int) {
		(shiniesValue.superview as? UIStackView)?.arrangedSubviews.compactMap { $0 as? UILabel }.first?.text = shiniesCaption
		shiniesValue.superview?.superview?.accessibilityLabel = shiniesCaption.capitalized
		shiniesValue.text = shinies.grouped
		speciesValue.text = species.grouped
		encountersValue.text = encounters.grouped
		shiniesValue.superview?.superview?.accessibilityValue = shinies.grouped
		speciesValue.superview?.superview?.accessibilityValue = species.grouped
		encountersValue.superview?.superview?.accessibilityValue = encounters.grouped
		sortControl.selectedSegmentIndex = sortIndex
	}

	@objc fileprivate func sortChanged() {
		onSortChanged?(sortControl.selectedSegmentIndex)
	}
}

fileprivate class CollectionCard: UICollectionViewCell {
	static let reuseIdentifier = "collectionCard"

	fileprivate let glowView = GlowView()
	fileprivate let spriteView = UIImageView()
	fileprivate let ballView = UIImageView()
	fileprivate let nameLabel = UILabel(fontSize: 14, weight: .semibold)
	fileprivate let speciesLabel = UILabel(fontSize: 11, weight: .medium, color: Color.Grey300)
	fileprivate let dateLabel = UILabel(fontSize: 11, color: Color.Grey400)

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = Color.Grey800
		contentView.layer.cornerRadius = 14
		contentView.clipsToBounds = true
		isAccessibilityElement = true
		accessibilityTraits = .button

		for imageView in [spriteView, ballView] {
			imageView.contentMode = .scaleAspectFit
			imageView.layer.magnificationFilter = .nearest
		}
		nameLabel.textAlignment = .center
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.75
		speciesLabel.textAlignment = .center
		speciesLabel.adjustsFontSizeToFitWidth = true
		speciesLabel.minimumScaleFactor = 0.8
		dateLabel.textAlignment = .center
		dateLabel.adjustsFontSizeToFitWidth = true
		dateLabel.minimumScaleFactor = 0.8

		contentView.addAutoLayoutSubviews(glowView, spriteView, ballView, nameLabel, speciesLabel, dateLabel)
		NSLayoutConstraint.activate([
			spriteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -4),
			spriteView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			spriteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
			spriteView.heightAnchor.constraint(equalTo: spriteView.widthAnchor),

			glowView.centerXAnchor.constraint(equalTo: spriteView.centerXAnchor),
			glowView.centerYAnchor.constraint(equalTo: spriteView.centerYAnchor, constant: 14),
			glowView.widthAnchor.constraint(equalTo: spriteView.widthAnchor, multiplier: 0.9),
			glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),

			ballView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			ballView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
			ballView.widthAnchor.constraint(equalToConstant: 24),
			ballView.heightAnchor.constraint(equalToConstant: 24),

			nameLabel.topAnchor.constraint(equalTo: spriteView.bottomAnchor, constant: -10),
			nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
			speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1),
			speciesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			speciesLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			dateLabel.topAnchor.constraint(equalTo: speciesLabel.bottomAnchor, constant: 1),
			dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
			dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			UIView.animate(withDuration: 0.15) {
				self.contentView.backgroundColor = self.isHighlighted ? Color.Grey700 : Color.Grey800
				self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
			}
		}
	}

	func configure(caught: CatchSummary) {
		spriteView.image = UIImage(named: caught.pokemonName.lowercased())
		spriteView.alpha = caught.isFailed ? 0.55 : 1
		glowView.isHidden = caught.isFailed
		ballView.image = caught.isFailed ? UIImage.makeSymbol("wind", pointSize: 14, weight: .semibold) : UIImage(named: caught.caughtBall)
		ballView.tintColor = Color.Grey400
		ballView.contentMode = caught.isFailed ? .center : .scaleAspectFit
		nameLabel.text = caught.nickname ?? caught.pokemonName
		speciesLabel.text = caught.pokemonName
		speciesLabel.isHidden = caught.nickname == nil
		dateLabel.text = caught.formattedCaughtDate ?? "Before history"
		let detail = caught.isFailed ? "got away" : caught.ballName
		accessibilityLabel = [caught.nickname, "Shiny \(caught.pokemonName)", detail, caught.formattedCaughtDate ?? "date unknown"].compactMap { $0 }.joined(separator: ", ")
	}
}
