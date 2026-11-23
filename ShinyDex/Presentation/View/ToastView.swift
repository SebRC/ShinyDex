import UIKit

class ToastView: UIView {
	let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
	fileprivate let messageLabel = UILabel()

	init(text: String, symbolName: String = "checkmark.circle.fill", tintColor: UIColor = Color.success, textColor: UIColor = Color.Success100) {
		super.init(frame: .zero)
		backgroundColor = Color.surface
		layer.cornerRadius = CornerRadius.standard
		addShadow()

		iconImageView.image = UIImage(systemName: symbolName)
		iconImageView.tintColor = tintColor
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.setContentHuggingPriority(.required, for: .horizontal)
		iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)

		messageLabel.text = text
		messageLabel.textColor = textColor
		messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		messageLabel.adjustsFontForContentSizeCategory = true
		messageLabel.numberOfLines = 0

		let stack = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
		stack.spacing = 10
		stack.alignment = .center
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
		])

		isAccessibilityElement = true
		accessibilityLabel = text
		accessibilityTraits = .staticText
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
