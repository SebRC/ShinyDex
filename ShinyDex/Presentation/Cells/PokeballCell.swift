import UIKit

class PokeballCell: UICollectionViewCell {
	static let reuseIdentifier = "pokeballCell"

	fileprivate let tileView = UIView()
	fileprivate let pokeballImageView = UIImageView()
	fileprivate let nameLabel = UILabel(fontSize: 13, color: Color.Grey300, lines: 2)

	override init(frame: CGRect) {
		super.init(frame: frame)
		isAccessibilityElement = true
		accessibilityTraits = .button
		tileView.backgroundColor = Color.Grey800
		tileView.layer.cornerRadius = 14
		tileView.layer.borderColor = Color.Orange500.cgColor
		pokeballImageView.contentMode = .scaleAspectFit
		pokeballImageView.layer.magnificationFilter = .nearest
		nameLabel.textAlignment = .center
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.8

		tileView.addAutoLayoutSubviews(pokeballImageView)
		contentView.addAutoLayoutSubviews(tileView, nameLabel)
		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tileView.heightAnchor.constraint(equalTo: tileView.widthAnchor),
			pokeballImageView.centerXAnchor.constraint(equalTo: tileView.centerXAnchor),
			pokeballImageView.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
			pokeballImageView.widthAnchor.constraint(equalTo: tileView.widthAnchor, multiplier: 0.8),
			pokeballImageView.heightAnchor.constraint(equalTo: pokeballImageView.widthAnchor),

			nameLabel.topAnchor.constraint(equalTo: tileView.bottomAnchor, constant: 6),
			nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			tileView.backgroundColor = isHighlighted ? Color.Grey700 : Color.Grey800
		}
	}

	func configure(item: IconGridItem, isCurrent: Bool) {
		pokeballImageView.image = item.image
		nameLabel.text = item.title
		tileView.layer.borderWidth = isCurrent ? 2 : 0
		accessibilityLabel = item.accessibilityLabel ?? item.title
		accessibilityTraits = isCurrent ? [.button, .selected] : .button
	}
}
