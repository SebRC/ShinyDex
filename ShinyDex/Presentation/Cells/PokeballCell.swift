import UIKit

class PokeballCell: UICollectionViewCell {
	static let reuseIdentifier = "pokeballCell"

	fileprivate let tileView = UIView()
	fileprivate let pokeballImageView = UIImageView()
	fileprivate let nameLabel = UILabel(style: .footnote, color: Color.textSecondary, lines: 2)
	fileprivate let detailLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textQuaternary)

	override init(frame: CGRect) {
		super.init(frame: frame)
		isAccessibilityElement = true
		accessibilityTraits = .button
		tileView.backgroundColor = Color.surface
		tileView.layer.cornerRadius = CornerRadius.standard
		tileView.layer.borderColor = Color.accent.cgColor
		pokeballImageView.contentMode = .scaleAspectFit
		pokeballImageView.layer.magnificationFilter = .nearest
		nameLabel.textAlignment = .center
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.8

		detailLabel.textAlignment = .center
		detailLabel.adjustsFontSizeToFitWidth = true
		detailLabel.minimumScaleFactor = 0.8
		let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
		labels.axis = .vertical
		labels.spacing = 1

		tileView.addAutoLayoutSubviews(pokeballImageView)
		contentView.addAutoLayoutSubviews(tileView, labels)
		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tileView.heightAnchor.constraint(equalTo: tileView.widthAnchor),
			pokeballImageView.centerXAnchor.constraint(equalTo: tileView.centerXAnchor),
			pokeballImageView.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),
			pokeballImageView.widthAnchor.constraint(equalTo: tileView.widthAnchor, multiplier: 0.8),
			pokeballImageView.heightAnchor.constraint(equalTo: pokeballImageView.widthAnchor),

			labels.topAnchor.constraint(equalTo: tileView.bottomAnchor, constant: 6),
			labels.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			labels.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			labels.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			tileView.backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
		}
	}

	func configure(item: IconGridItem, isCurrent: Bool) {
		pokeballImageView.image = item.image
		pokeballImageView.alpha = item.isDimmed ? 0.35 : 1
		nameLabel.text = item.title
		nameLabel.textColor = item.isDimmed ? Color.textQuaternary : Color.textSecondary
		detailLabel.text = item.detail
		detailLabel.isHidden = item.detail == nil
		tileView.layer.borderWidth = isCurrent ? 2 : 0
		accessibilityLabel = item.accessibilityLabel ?? item.title
		accessibilityTraits = isCurrent ? [.button, .selected] : .button
	}
}
