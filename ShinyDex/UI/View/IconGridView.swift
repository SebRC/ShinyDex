import UIKit

/// A full-width row under the grid, like "Shiny got away" or "Remove latest catch".
struct IconGridAction {
	let title: String
	let symbol: String
	var isDestructive = false
}

/// One tile in an `IconGridView`.
struct IconGridItem {
	let title: String
	let image: UIImage?
	var accessibilityLabel: String? = nil
}

/// The grid used everywhere something with an icon is chosen: balls, games and hunt methods.
/// The current choice gets an orange outline; optional full-width action rows sit under the grid.
class IconGridView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
	fileprivate enum Section: Int, CaseIterable {
		case items
		case actions
	}

	fileprivate static let headerKind = "sectionHeader"

	var items = [IconGridItem]() {
		didSet { collectionView.reloadData() }
	}
	var currentIndex: Int? {
		didSet { collectionView.reloadData() }
	}
	var caption = "" {
		didSet { collectionView.reloadData() }
	}
	var actions = [IconGridAction]() {
		didSet { collectionView.reloadData() }
	}
	var onSelect: ((Int) -> Void)?
	/// Called with the index into `actions`.
	var onAction: ((Int) -> Void)?

	fileprivate let columns: Int
	fileprivate var collectionView: UICollectionView!

	/// Four columns suit short names like balls; three leave room for longer ones like game titles.
	init(columns: Int = 4) {
		self.columns = columns
		super.init(frame: .zero)
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceVertical = true
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(PokeballCell.self, forCellWithReuseIdentifier: PokeballCell.reuseIdentifier)
		collectionView.register(ActionCell.self, forCellWithReuseIdentifier: ActionCell.reuseIdentifier)
		collectionView.register(GridHeaderView.self, forSupplementaryViewOfKind: IconGridView.headerKind, withReuseIdentifier: GridHeaderView.reuseIdentifier)
		addAutoLayoutSubviews(collectionView)
		collectionView.pinEdges(to: self)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Brings the current choice into view, for when it's further down the grid.
	func scrollToCurrentItem() {
		guard let index = currentIndex, index < items.count else { return }
		collectionView.layoutIfNeeded()
		collectionView.scrollToItem(at: IndexPath(item: index, section: Section.items.rawValue), at: .centeredVertically, animated: false)
	}

	fileprivate func makeLayout() -> UICollectionViewLayout {
		let columns = self.columns
		return UICollectionViewCompositionalLayout { sectionIndex, _ in
			if (Section(rawValue: sectionIndex) == .actions) {
				let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)])
				let section = NSCollectionLayoutSection(group: group)
				section.interGroupSpacing = 10
				section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
				return section
			}
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / CGFloat(columns)), heightDimension: .estimated(110))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(110))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			let section = NSCollectionLayoutSection(group: group)
			section.interGroupSpacing = 14
			section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 11, bottom: 16, trailing: 11)
			let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
			let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: IconGridView.headerKind, alignment: .top)
			header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
			section.boundarySupplementaryItems = [header]
			return section
		}
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return actions.isEmpty ? 1 : Section.allCases.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Section(rawValue: section) == .items ? items.count : actions.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if (Section(rawValue: indexPath.section) == .actions) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionCell.reuseIdentifier, for: indexPath) as! ActionCell
			cell.configure(action: actions[indexPath.item])
			return cell
		}
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokeballCell.reuseIdentifier, for: indexPath) as! PokeballCell
		cell.configure(item: items[indexPath.item], isCurrent: indexPath.item == currentIndex)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GridHeaderView.reuseIdentifier, for: indexPath) as! GridHeaderView
		header.label.text = caption
		return header
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if (Section(rawValue: indexPath.section) == .actions) {
			onAction?(indexPath.item)
		}
		else {
			onSelect?(indexPath.item)
		}
	}
}

/// The balls you can log, shared by every ball grid.
enum BallGrid {
	/// "None" is left out: it isn't a ball, and removing a catch is its own action.
	static let ballNames = TxtReader().readFile(textFile: "pokeballs").filter { $0 != CatchRules.noBall }

	static var items: [IconGridItem] {
		return ballNames.map { name in
			let pokeball = Pokeball(ballName: name)
			return IconGridItem(title: pokeball.name, image: pokeball.image, accessibilityLabel: "\(pokeball.name) Ball")
		}
	}

	static func index(of ball: String?) -> Int? {
		return ball.flatMap { ballNames.firstIndex(of: $0) }
	}
}

/// A pushed screen for choosing one option from an icon grid. Picking an option saves it and goes back.
class GridPickerVC: UIViewController {
	let gridView: IconGridView
	fileprivate let onPick: (Int) -> Void

	init(title: String, caption: String, items: [IconGridItem], columns: Int = 4, currentIndex: Int?, onPick: @escaping (Int) -> Void) {
		gridView = IconGridView(columns: columns)
		self.onPick = onPick
		super.init(nibName: nil, bundle: nil)
		self.title = title
		gridView.caption = caption.uppercased()
		gridView.items = items
		gridView.currentIndex = currentIndex
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
		view.backgroundColor = Color.Grey900
		gridView.onSelect = { [weak self] index in
			guard let self = self else { return }
			Haptics.tap()
			self.onPick(index)
			self.navigationController?.popViewController(animated: true)
		}
		view.addAutoLayoutSubviews(gridView)
		NSLayoutConstraint.activate([
			gridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
			gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		gridView.scrollToCurrentItem()
	}
}

/// Small uppercase caption above the grid, matching grouped table headers.
fileprivate class GridHeaderView: UICollectionReusableView {
	static let reuseIdentifier = "gridHeader"
	let label = UILabel(fontSize: 13, color: Color.Grey400)

	override init(frame: CGRect) {
		super.init(frame: frame)
		addAutoLayoutSubviews(label)
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

/// A full-width action row under the grid; destructive actions are red.
fileprivate class ActionCell: UICollectionViewCell {
	static let reuseIdentifier = "gridActionCell"

	fileprivate let label = UILabel(fontSize: 17)
	fileprivate let icon = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = Color.Grey800
		contentView.layer.cornerRadius = CornerRadius.standard
		let row = UIStackView(arrangedSubviews: [icon, label])
		row.spacing = 8
		row.alignment = .center
		contentView.addAutoLayoutSubviews(row)
		NSLayoutConstraint.activate([
			row.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			row.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
		isAccessibilityElement = true
		accessibilityTraits = .button
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(action: IconGridAction) {
		let color = action.isDestructive ? Color.Danger400 : Color.Grey200
		label.text = action.title
		label.textColor = color
		icon.image = UIImage.symbol(action.symbol, pointSize: 16, weight: .semibold)
		icon.tintColor = color
		accessibilityLabel = action.title
	}

	override var isHighlighted: Bool {
		didSet {
			contentView.backgroundColor = isHighlighted ? Color.Grey700 : Color.Grey800
		}
	}
}
