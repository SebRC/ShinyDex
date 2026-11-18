import UIKit

class CatchCountBadge: UILabel {
	static let height: CGFloat = 16

	init() {
		super.init(frame: .zero)
		font = UIFont.boldSystemFont(ofSize: 11)
		textAlignment = .center
		textColor = Color.Grey900
		backgroundColor = Color.Orange500
		layer.cornerRadius = CatchCountBadge.height / 2
		clipsToBounds = true
		isUserInteractionEnabled = false
		translatesAutoresizingMaskIntoConstraints = false
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func attached(to ballButton: UIView) -> CatchCountBadge {
		if let existing = ballButton.subviews.compactMap({ $0 as? CatchCountBadge }).first {
			return existing
		}
		let badge = CatchCountBadge()
		ballButton.clipsToBounds = false
		ballButton.addSubview(badge)
		// The ball art only fills the middle of its image, so the badge is placed from the centre to overlap its edge.
		NSLayoutConstraint.activate([
			badge.heightAnchor.constraint(equalToConstant: CatchCountBadge.height),
			badge.widthAnchor.constraint(greaterThanOrEqualToConstant: CatchCountBadge.height),
			badge.leadingAnchor.constraint(equalTo: ballButton.centerXAnchor, constant: 8),
			badge.bottomAnchor.constraint(equalTo: ballButton.centerYAnchor, constant: -7)
		])
		return badge
	}

	func show(count: Int) {
		text = " ×\(count) "
		isHidden = count < 2
	}
}
