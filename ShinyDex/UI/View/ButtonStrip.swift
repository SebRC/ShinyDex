import UIKit

/// One action in the tracker's action bar: an icon with a short caption underneath, tappable as a whole.
class ActionButton: UIControl {
	static let iconSize: CGFloat = 28

	let iconView = UIImageView()
	fileprivate let captionLabel = UILabel(fontSize: 11, weight: .medium, color: Color.Grey400)

	init(caption: String) {
		super.init(frame: .zero)
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityLabel = caption
		iconView.contentMode = .scaleAspectFit
		iconView.tintColor = Color.Grey200
		iconView.layer.magnificationFilter = .nearest
		captionLabel.text = caption
		captionLabel.textAlignment = .center
		captionLabel.adjustsFontSizeToFitWidth = true
		captionLabel.minimumScaleFactor = 0.8

		let stack = UIStackView(arrangedSubviews: [iconView, captionLabel])
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 4
		stack.isUserInteractionEnabled = false
		addAutoLayoutSubviews(stack)
		NSLayoutConstraint.activate([
			stack.centerYAnchor.constraint(equalTo: centerYAnchor),
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
			iconView.widthAnchor.constraint(equalToConstant: ActionButton.iconSize),
			iconView.heightAnchor.constraint(equalToConstant: ActionButton.iconSize),
			heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		didSet {
			alpha = isHighlighted ? 0.5 : 1
		}
	}

	override var isEnabled: Bool {
		didSet {
			alpha = isEnabled ? 1 : 0.35
		}
	}
}

/// The tracker's action bar: set encounters, encounters per tap, game and method, location, and log a catch.
/// Every action has a caption, so the row reads without having to learn what each icon means.
class ButtonStrip: UIView {
	/// Point size for the SF Symbol icons, chosen to sit at the same visual weight as the image icons beside them.
	static let symbolPointSize: CGFloat = 22

	let updateEncountersButton = ActionButton(caption: "Edit count")
	let incrementButton = ActionButton(caption: "Per tap")
	let methodButton = ActionButton(caption: "Method")
	let locationButton = ActionButton(caption: "Location")
	let pokeballButton = ActionButton(caption: "Log catch")

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard

		updateEncountersButton.iconView.image = UIImage.symbol("pencil", pointSize: ButtonStrip.symbolPointSize, weight: .medium)
		updateEncountersButton.iconView.contentMode = .center
		incrementButton.iconView.contentMode = .center
		locationButton.iconView.image = UIImage(named: "town-map")
		// Logging a catch is an action, so it gets the same sparkles as the Pokédex rows instead of the caught ball.
		pokeballButton.iconView.image = UIImage.symbol(PokemonCell.logCatchSymbol, pointSize: ButtonStrip.symbolPointSize, weight: .medium)
		pokeballButton.iconView.contentMode = .center
		pokeballButton.iconView.tintColor = Color.Orange500

		let stack = UIStackView(arrangedSubviews: [updateEncountersButton, incrementButton, methodButton, locationButton, pokeballButton])
		stack.distribution = .fillEqually
		addAutoLayoutSubviews(stack)
		stack.pinEdges(to: self, insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
