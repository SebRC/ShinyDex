import UIKit

/// A short confirmation message shown at the top of the screen, below the status bar / Dynamic Island.
class ToastView: UIView {
	fileprivate let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
	fileprivate let messageLabel = UILabel()

	init(text: String) {
		super.init(frame: .zero)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard
		addShadow()

		iconImageView.tintColor = Color.Success300
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.setContentHuggingPriority(.required, for: .horizontal)
		iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline)

		messageLabel.text = text
		messageLabel.textColor = Color.Success100
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
