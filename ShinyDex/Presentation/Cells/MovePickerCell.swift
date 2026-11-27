import UIKit

class TypeIconView: UIView {
	fileprivate let imageView = UIImageView()

	init(size: CGFloat) {
		super.init(frame: .zero)
		isAccessibilityElement = false
		layer.cornerRadius = size / 2
		imageView.contentMode = .scaleAspectFit
		addAutoLayoutSubviews(imageView)
		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: size),
			heightAnchor.constraint(equalToConstant: size),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.58),
			imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.58)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setType(_ type: String) {
		imageView.image = UIImage(named: type.lowercased())
		backgroundColor = MoveTypes.colors[type] ?? Color.inactive
	}
}

class MovePickerCell: UITableViewCell {
	static let reuseIdentifier = "movePickerCell"

	fileprivate let typeIconView = TypeIconView(size: 36)
	fileprivate let nameLabel = UILabel(style: .body, weight: .semibold)
	fileprivate let detailLabel = UILabel(style: .subheadline, color: Color.textTertiary)
	fileprivate let originLabel = UILabel(style: .footnote, weight: .semibold, color: Color.accent)
	fileprivate let inUseLabel = UILabel(style: .subheadline, color: Color.textQuaternary)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.surface
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.surfaceRaised
		selectedBackgroundView = selectedBackground
		inUseLabel.text = "In use"
		inUseLabel.setContentHuggingPriority(.required, for: .horizontal)
		inUseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		originLabel.numberOfLines = 0
		let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel, originLabel])
		labels.axis = .vertical
		labels.spacing = 2
		let row = UIStackView(arrangedSubviews: [typeIconView, labels, inUseLabel])
		row.alignment = .center
		row.spacing = 12
		contentView.addAutoLayoutSubviews(row)
		NSLayoutConstraint.activate([
			row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(name: String, maxPP: Int, type: String, isInUse: Bool, origin: String? = nil) {
		nameLabel.text = name
		detailLabel.text = "\(type) · \(maxPP) PP"
		originLabel.text = origin
		originLabel.isHidden = origin == nil
		typeIconView.setType(type)
		inUseLabel.isHidden = !isInUse
		accessibilityLabel = ["\(name), \(type), \(maxPP) PP", origin, isInUse ? "in use" : nil].compactMap { $0 }.joined(separator: ", ")
	}
}
