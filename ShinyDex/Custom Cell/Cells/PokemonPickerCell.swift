import UIKit

class PokemonPickerCell: UITableViewCell {
	static let reuseIdentifier = "pokemonPickerCell"

	let spriteImageView = UIImageView()
	let nameLabel = UILabel(fontSize: 17, weight: .semibold)
	let numberLabel = UILabel(fontSize: 15, color: Color.Grey400)
	fileprivate let selectionView = UIImageView()
	fileprivate let inHuntLabel = UILabel(fontSize: 13, color: Color.Grey500)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		spriteImageView.contentMode = .scaleAspectFit
		spriteImageView.layer.magnificationFilter = .nearest
		spriteImageView.isAccessibilityElement = false
		numberLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
		selectionView.contentMode = .center
		selectionView.setContentHuggingPriority(.required, for: .horizontal)
		inHuntLabel.text = "In a hunt"
		inHuntLabel.setContentHuggingPriority(.required, for: .horizontal)
		inHuntLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		let labels = UIStackView(arrangedSubviews: [nameLabel, numberLabel])
		labels.axis = .vertical
		labels.spacing = 1
		let row = UIStackView(arrangedSubviews: [spriteImageView, labels, inHuntLabel, selectionView])
		row.alignment = .center
		row.spacing = 12
		contentView.addAutoLayoutSubviews(row)
		NSLayoutConstraint.activate([
			row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			spriteImageView.widthAnchor.constraint(equalToConstant: 56),
			spriteImageView.heightAnchor.constraint(equalToConstant: 56),
			selectionView.widthAnchor.constraint(equalToConstant: 28)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(pokemon: Pokemon, isSelected: Bool, isInOtherHunt: Bool) {
		spriteImageView.image = UIImage(named: pokemon.name.lowercased())
		nameLabel.text = pokemon.name
		numberLabel.text = String(format: "No. %03d", pokemon.number + 1)

		spriteImageView.alpha = isInOtherHunt ? 0.4 : 1
		nameLabel.alpha = isInOtherHunt ? 0.45 : 1
		numberLabel.alpha = isInOtherHunt ? 0.6 : 1
		inHuntLabel.isHidden = !isInOtherHunt
		selectionView.isHidden = isInOtherHunt
		selectionView.image = UIImage.symbol(isSelected ? "checkmark.circle.fill" : "circle", pointSize: 24, weight: .regular)
		selectionView.tintColor = isSelected ? Color.Orange500 : Color.Grey600
		selectionStyle = isInOtherHunt ? .none : .default

		accessibilityLabel = "\(pokemon.name), number \(pokemon.number + 1)"
		accessibilityTraits = isInOtherHunt ? [.button, .notEnabled] : (isSelected ? [.button, .selected] : .button)
		accessibilityHint = isInOtherHunt ? "Already in a hunt." : (isSelected ? "Removes \(pokemon.name) from your picks." : "Adds \(pokemon.name) to your picks.")
	}
}
