import UIKit

/// A Pokémon in a Pokédex list: sprite, name, dex number and a status line (caught / in a hunt),
/// with round buttons to log a catch (orange sparkles) and add it to a hunt (grey plus).
/// The ball it was caught in is shown in the status line as information, never as a button.
class PokemonCell: UITableViewCell {
	static let reuseIdentifier = "pokemonCell"

	var onCaughtPressed: (() -> Void)?
	var onAddToHuntPressed: (() -> Void)?

	let sprite = UIImageView()
	let pokemonName = UILabel(fontSize: 17, weight: .semibold)
	let pokemonNumber = UILabel(fontSize: 13, color: Color.Grey400)
	let caughtButton = PokemonCell.makeRoundButton(symbol: PokemonCell.logCatchSymbol, tint: Color.Orange500, background: Color.Orange900)
	let addToCurrentHuntButton = PokemonCell.makeRoundButton(symbol: "plus", tint: Color.Grey200, background: Color.Grey700)

	/// Sparkles read as "shiny" and differ clearly from the hunt button's plus; iOS 13 lacks the symbol, so it falls back to a star.
	static let logCatchSymbol = UIImage(systemName: "sparkles") != nil ? "sparkles" : "star.fill"
	fileprivate static let buttonSize: CGFloat = 38
	fileprivate let statusIcon = UIImageView()
	fileprivate let statusLabel = UILabel(fontSize: 13, weight: .medium)
	fileprivate let statusRow = UIStackView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest
		sprite.isAccessibilityElement = false
		pokemonNumber.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
		caughtButton.addTarget(self, action: #selector(caughtPressed), for: .touchUpInside)
		addToCurrentHuntButton.addTarget(self, action: #selector(addToHuntPressed), for: .touchUpInside)
		statusIcon.contentMode = .scaleAspectFit
		statusIcon.layer.magnificationFilter = .nearest

		statusRow.addArrangedSubview(statusIcon)
		statusRow.addArrangedSubview(statusLabel)
		statusRow.spacing = 4
		statusRow.alignment = .center
		let nameRow = UIStackView(arrangedSubviews: [pokemonName, pokemonNumber])
		nameRow.spacing = 6
		nameRow.alignment = .firstBaseline
		let labels = UIStackView(arrangedSubviews: [nameRow, statusRow])
		labels.axis = .vertical
		labels.alignment = .leading
		labels.spacing = 3
		let buttons = UIStackView(arrangedSubviews: [caughtButton, addToCurrentHuntButton])
		buttons.spacing = 8
		buttons.setContentHuggingPriority(.required, for: .horizontal)

		let row = UIStackView(arrangedSubviews: [sprite, labels, buttons])
		row.alignment = .center
		row.spacing = 10
		contentView.addAutoLayoutSubviews(row)
		NSLayoutConstraint.activate([
			row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
			row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			sprite.widthAnchor.constraint(equalToConstant: 60),
			sprite.heightAnchor.constraint(equalToConstant: 60),
			statusIcon.widthAnchor.constraint(equalToConstant: 16),
			statusIcon.heightAnchor.constraint(equalToConstant: 16),
			caughtButton.widthAnchor.constraint(equalToConstant: PokemonCell.buttonSize),
			caughtButton.heightAnchor.constraint(equalToConstant: PokemonCell.buttonSize),
			addToCurrentHuntButton.widthAnchor.constraint(equalToConstant: PokemonCell.buttonSize),
			addToCurrentHuntButton.heightAnchor.constraint(equalToConstant: PokemonCell.buttonSize)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeRoundButton(symbol: String, tint: UIColor, background: UIColor) -> UIButton {
		let button = UIButton(type: .system)
		button.setImage(UIImage.symbol(symbol, pointSize: 16, weight: .bold), for: .normal)
		button.tintColor = tint
		button.backgroundColor = background
		button.layer.cornerRadius = buttonSize / 2
		return button
	}

	/// Caught wins over "in a hunt", since the hunt is over once it's caught; with neither, the line is hidden.
	/// When caught, the line leads with the ball of the latest catch.
	func setStatus(catchCount: Int, caughtBall: String, isBeingHunted: Bool) {
		if (catchCount > 0) {
			statusIcon.image = UIImage(named: caughtBall)
			statusIcon.tintColor = nil
			statusLabel.textColor = Color.Orange500
			statusLabel.text = catchCount == 1 ? "Caught" : "Caught ×\(catchCount)"
			statusRow.isHidden = false
		}
		else if (isBeingHunted) {
			statusIcon.image = UIImage.symbol("scope", pointSize: 11, weight: .bold)
			statusIcon.tintColor = Color.Grey400
			statusLabel.textColor = Color.Grey400
			statusLabel.text = "In a hunt"
			statusRow.isHidden = false
		}
		else {
			statusRow.isHidden = true
		}
		addToCurrentHuntButton.setImage(UIImage.symbol(isBeingHunted ? "checkmark" : "plus", pointSize: 16, weight: .bold), for: .normal)
		addToCurrentHuntButton.isEnabled = !isBeingHunted
		addToCurrentHuntButton.alpha = isBeingHunted ? 0.45 : 1
	}

	@objc fileprivate func caughtPressed() {
		onCaughtPressed?()
	}

	@objc fileprivate func addToHuntPressed() {
		onAddToHuntPressed?()
	}
}
