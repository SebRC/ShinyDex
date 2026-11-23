import UIKit

final class RegionStripCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    struct Region {
        let index: Int
        let title: String
        let image: UIImage?
        let caught: Int
        let total: Int
    }

    static let reuseIdentifier = "regionStripCell"
    fileprivate static let cardSize = CGSize(width: 132, height: 112)

    var onSelect: ((Int) -> Void)?
    fileprivate var regions = [Region]()
    fileprivate let collectionView: UICollectionView

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = RegionStripCell.cardSize
        layout.minimumLineSpacing = Spacing.small
        layout.sectionInset = UIEdgeInsets(top: 0, left: Spacing.medium, bottom: 0, right: Spacing.medium)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        selectionStyle = .none
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RegionCard.self, forCellWithReuseIdentifier: RegionCard.reuseIdentifier)
        contentView.addAutoLayoutSubviews(collectionView)
        collectionView.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: 0, bottom: Spacing.medium, right: 0))
        collectionView.heightAnchor.constraint(equalToConstant: RegionStripCell.cardSize.height).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(regions: [Region]) {
        self.regions = regions
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return regions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = collectionView.dequeueReusableCell(withReuseIdentifier: RegionCard.reuseIdentifier, for: indexPath) as! RegionCard
        card.configure(region: regions[indexPath.item])
        return card
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(regions[indexPath.item].index)
    }
}

fileprivate final class RegionCard: UICollectionViewCell {
    static let reuseIdentifier = "regionCard"
    fileprivate static let imageHeight: CGFloat = 40

    fileprivate let imageView = UIImageView()
    fileprivate let titleLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let progressLabel = UILabel(style: .caption1, color: Color.textTertiary)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Color.surfaceRaised
        contentView.layer.cornerRadius = CornerRadius.standard
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        progressLabel.font = UIFont.make(.caption1, monospacedDigits: true)
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.minimumScaleFactor = 0.7
        progressBar.progressTintColor = Color.accent
        progressBar.trackTintColor = Color.surface
        progressBar.layer.cornerRadius = CornerRadius.tiny
        progressBar.clipsToBounds = true
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, progressLabel, progressBar])
        stack.axis = .vertical
        stack.spacing = 2
        stack.setCustomSpacing(Spacing.extraSmall, after: imageView)
        stack.setCustomSpacing(Spacing.extraSmall, after: progressLabel)
        contentView.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.small, bottom: Spacing.small, right: Spacing.small))
        NSLayoutConstraint.activate([
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            imageView.heightAnchor.constraint(equalToConstant: RegionCard.imageHeight)
        ])
        for label in [titleLabel, progressLabel] {
            label.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? 0.7 : 1
        }
    }

    func configure(region: RegionStripCell.Region) {
        imageView.image = region.image
        titleLabel.text = region.title
        progressLabel.text = "\(region.caught)/\(region.total) caught"
        progressBar.progress = region.total > 0 ? Float(region.caught) / Float(region.total) : 0
        accessibilityLabel = "\(region.title), \(region.caught) of \(region.total) caught"
    }
}

final class MenuToolGridCell: UITableViewCell {
    struct Tool {
        let title: String
        let symbolName: String
    }

    static let reuseIdentifier = "menuToolGridCell"
    fileprivate static let columns = 2

    var onSelect: ((Int) -> Void)?
    fileprivate let grid = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        backgroundConfiguration = .clear()
        selectionStyle = .none
        grid.axis = .vertical
        grid.spacing = Spacing.small
        contentView.addAutoLayoutSubviews(grid)
        grid.pinEdges(to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(tools: [Tool]) {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for rowStart in stride(from: 0, to: tools.count, by: MenuToolGridCell.columns) {
            let row = UIStackView()
            row.distribution = .fillEqually
            row.spacing = Spacing.small
            for index in rowStart..<min(rowStart + MenuToolGridCell.columns, tools.count) {
                let tile = MenuToolTile(tool: tools[index])
                tile.addAction(UIAction { [weak self] _ in self?.onSelect?(index) }, for: .touchUpInside)
                row.addArrangedSubview(tile)
            }
            grid.addArrangedSubview(row)
        }
    }
}

fileprivate final class MenuToolTile: UIControl {
    init(tool: MenuToolGridCell.Tool) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        let icon = UIImageView(image: UIImage.makeSymbol(tool.symbolName, pointSize: 20, weight: .medium))
        icon.tintColor = Color.accent
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)
        let title = UILabel(style: .subheadline, weight: .semibold, lines: 2)
        title.text = tool.title
        let stack = UIStackView(arrangedSubviews: [icon, title])
        stack.spacing = Spacing.small
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.small))
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
        isAccessibilityElement = true
        accessibilityLabel = tool.title
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
        }
    }
}
