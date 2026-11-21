import UIKit

struct IconGridAction {
    let title: String
    let symbol: String
    var isDestructive = false
}

struct IconGridItem {
    let title: String
    let image: UIImage?
    var accessibilityLabel: String? = nil
    var isDimmed = false
    var detail: String? = nil
}

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
    var onAction: ((Int) -> Void)?

    fileprivate let columns: Int
    fileprivate var collectionView: UICollectionView!

    init(columns: Int = 4) {
        self.columns = columns
        super.init(frame: .zero)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.bottom = Spacing.extraLarge
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
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 15, bottom: 16, trailing: 15)
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

struct BallGrid {
    let ballNames: [String]

    init(container: AppContainer) {
        ballNames = container.getBallNames.handle(GetBallNamesQuery())
    }

    var items: [IconGridItem] {
        return ballNames.map { name in
            let title = BallGrid.getDisplayName(of: name)
            return IconGridItem(title: title, image: UIImage(named: name), accessibilityLabel: "\(title) Ball")
        }
    }

    func findIndex(of ball: String?) -> Int? {
        return ball.flatMap { ballNames.firstIndex(of: $0) }
    }

    static func getDisplayName(of ball: String) -> String {
        return ball.capitalizingFirstLetter()
    }
}

class GridPickerVC: UIViewController {
    let gridView: IconGridView
    fileprivate let onPick: (Int) -> Void

    fileprivate let legend: UIView?

    init(title: String, caption: String, items: [IconGridItem], columns: Int = 4, currentIndex: Int?, legend: UIView? = nil, onPick: @escaping (Int) -> Void) {
        gridView = IconGridView(columns: columns)
        self.legend = legend
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
        view.backgroundColor = Color.background
        gridView.onSelect = { [weak self] index in
            guard let self = self else { return }
            Haptics.tap()
            self.onPick(index)
            self.navigationController?.popViewController(animated: true)
        }
        view.addAutoLayoutSubviews(gridView)
        let gridTop: NSLayoutYAxisAnchor
        if let legend = legend {
            view.addAutoLayoutSubviews(legend)
            NSLayoutConstraint.activate([
                legend.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.small),
                legend.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.screenMargin),
                legend.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.screenMargin)
            ])
            gridTop = legend.bottomAnchor
        }
        else {
            gridTop = view.safeAreaLayoutGuide.topAnchor
        }
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: gridTop, constant: 8),
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

fileprivate class GridHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "gridHeader"
    let label = SectionHeaderLabel(horizontalInset: 0)

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

fileprivate class ActionCell: UICollectionViewCell {
    static let reuseIdentifier = "gridActionCell"

    fileprivate let label = UILabel(style: .body)
    fileprivate let icon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Color.surface
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
        let color = action.isDestructive ? Color.danger : Color.textPrimary
        label.text = action.title
        label.textColor = color
        icon.image = UIImage.makeSymbol(action.symbol, pointSize: 16, weight: .semibold)
        icon.tintColor = color
        accessibilityLabel = action.title
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
        }
    }
}
