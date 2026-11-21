import UIKit

class EmptyStateView: UIView {
	init(symbolName: String, title: String, message: String) {
		super.init(frame: .zero)

		let imageView = UIImageView(image: UIImage(systemName: symbolName))
		imageView.tintColor = Color.accent
		imageView.contentMode = .scaleAspectFit
		imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
		imageView.isAccessibilityElement = false

		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).withWeight(.semibold)
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.textColor = Color.textPrimary
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0

		let messageLabel = UILabel()
		messageLabel.text = message
		messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
		messageLabel.adjustsFontForContentSizeCategory = true
		messageLabel.textColor = Color.textTertiary
		messageLabel.textAlignment = .center
		messageLabel.numberOfLines = 0

		let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 8
		stack.setCustomSpacing(16, after: imageView)
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		NSLayoutConstraint.activate([
			stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
