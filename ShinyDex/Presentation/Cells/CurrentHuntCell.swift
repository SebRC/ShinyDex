import UIKit

class CurrentHuntCell: UITableViewCell {
    static let reuseIdentifier = "currentHuntCell"

    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?

    let sprite = UIImageView()
    let nameLabel = UILabel(style: .body, weight: .semibold)
    let encountersLabel = UILabel(style: .title1, weight: .bold)
    fileprivate let encountersCaption = UILabel(style: .footnote, color: Color.textTertiary)
    let minusButton = UIButton.makeSymbolButton("minus.circle.fill", pointSize: 32)
    let plusButton = UIButton.makeSymbolButton("plus.circle.fill", pointSize: 44)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .none
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        encountersLabel.font = UIFont.make(.title1, weight: .bold, monospacedDigits: true)
        encountersLabel.adjustsFontSizeToFitWidth = true
        encountersLabel.minimumScaleFactor = 0.6
        minusButton.tintColor = Color.textQuaternary
        plusButton.tintColor = Color.accent
        minusButton.addTarget(self, action: #selector(decrementPressed), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(incrementPressed), for: .touchUpInside)

        let countRow = UIStackView(arrangedSubviews: [encountersLabel, encountersCaption])
        countRow.spacing = 6
        countRow.alignment = .firstBaseline
        let labels = UIStackView(arrangedSubviews: [nameLabel, countRow])
        labels.axis = .vertical
        labels.spacing = 0
        labels.alignment = .leading
        let buttons = UIStackView(arrangedSubviews: [minusButton, plusButton])
        buttons.alignment = .center
        buttons.spacing = 4
        buttons.setContentHuggingPriority(.required, for: .horizontal)
        buttons.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [sprite, labels, buttons])
        row.alignment = .center
        row.spacing = 10
        contentView.addAutoLayoutSubviews(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64),
            minusButton.widthAnchor.constraint(equalToConstant: 48),
            minusButton.heightAnchor.constraint(equalToConstant: 48),
            plusButton.widthAnchor.constraint(equalToConstant: 56),
            plusButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(pokemon: HuntMember) {
        sprite.image = PokemonSprites.makeImage(pokemonName: pokemon.name)
        nameLabel.text = pokemon.name
        encountersLabel.text = pokemon.encounters.grouped
        encountersCaption.text = pokemon.encounters == 1 ? "encounter" : "encounters"
        minusButton.isEnabled = pokemon.encounters > 0
        plusButton.accessibilityLabel = pokemon.increment == 1
            ? "Add an encounter for \(pokemon.name)"
            : "Add \(pokemon.increment) encounters for \(pokemon.name)"
        minusButton.accessibilityLabel = "Remove an encounter for \(pokemon.name)"
        encountersLabel.accessibilityLabel = "\(pokemon.encounters) encounters"
    }

    @objc fileprivate func decrementPressed() {
        onDecrement?()
    }

    @objc fileprivate func incrementPressed() {
        onIncrement?()
    }
}
