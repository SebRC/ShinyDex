import UIKit

/// One row in the game settings: icon, title with a description of where it's available, and an on/off switch.
/// Rows sit inside grouped cards, so the row itself has no background; the card draws it.
class GameSettingsCell: UIView {
	let iconImageView = UIImageView()
	let titleLabel = UILabel(fontSize: 17, weight: .semibold)
	let descriptionLabel = UILabel(fontSize: 13, color: Color.Grey400, lines: 0)
	let actionSwitch = UISwitch()

	init(title: String, description: String, icon: UIImage?, tag: Int) {
		super.init(frame: .zero)
		titleLabel.text = title
		descriptionLabel.text = description
		iconImageView.image = icon
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.layer.magnificationFilter = .nearest
		iconImageView.isAccessibilityElement = false
		actionSwitch.tag = tag
		actionSwitch.accessibilityLabel = title
		actionSwitch.accessibilityHint = description
		actionSwitch.setContentHuggingPriority(.required, for: .horizontal)
		actionSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
		setUIColors()

		let labels = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
		labels.axis = .vertical
		labels.spacing = 2
		let row = UIStackView(arrangedSubviews: [iconImageView, labels, actionSwitch])
		row.alignment = .center
		row.spacing = 12
		addAutoLayoutSubviews(row)
		row.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
		NSLayoutConstraint.activate([
			iconImageView.widthAnchor.constraint(equalToConstant: 34),
			iconImageView.heightAnchor.constraint(equalToConstant: 34)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Dims a row the selected game doesn't support; its switch is already disabled by `SwitchStateService`.
	func setAvailable(_ isAvailable: Bool) {
		titleLabel.alpha = isAvailable ? 1 : 0.45
		descriptionLabel.alpha = isAvailable ? 1 : 0.7
		actionSwitch.alpha = isAvailable ? 1 : 0.45
	}

	func setUIColors() {
		backgroundColor = .clear
		titleLabel.textColor = Color.Grey200
		actionSwitch.onTintColor = Color.Orange500
	}
}
