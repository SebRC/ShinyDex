import UIKit

class PokemonCell: UITableViewCell {
    static let reuseIdentifier = "pokemonCell"

    var onCaughtPressed: (() -> Void)?
    var onAddToHuntPressed: (() -> Void)?

    let sprite = UIImageView()
    let pokemonName = UILabel(style: .body, weight: .semibold)
    let pokemonNumber = UILabel(style: .footnote, color: Color.textTertiary)
    let caughtButton = UIButton.makeRoundButton(.tinted, symbolName: PokemonCell.logCatchSymbol, diameter: PokemonCell.buttonSize)
    let addToCurrentHuntButton = UIButton.makeRoundButton(.secondary, symbolName: "plus", diameter: PokemonCell.buttonSize)

    static let logCatchSymbol = UIImage(systemName: "sparkles") != nil ? "sparkles" : "star.fill"
    fileprivate static let buttonSize: CGFloat = 38
    fileprivate let statusIcon = UIImageView()
    fileprivate let statusLabel = UILabel(style: .footnote, weight: .medium)
    fileprivate let statusRow = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        pokemonNumber.font = UIFont.make(.footnote, weight: .regular, monospacedDigits: true)
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

    func setStatus(catchCount: Int, caughtBall: String, isBeingHunted: Bool, shinyLockedGame: Games? = nil) {
        if (catchCount > 0) {
            statusIcon.image = UIImage(named: caughtBall)
            statusIcon.tintColor = nil
            statusLabel.textColor = Color.accent
            statusLabel.text = catchCount == 1 ? "Caught" : "Caught ×\(catchCount)"
            statusRow.isHidden = false
        }
        else if let game = shinyLockedGame {
            statusIcon.image = UIImage.makeSymbol("lock.fill", pointSize: 11, weight: .bold)
            statusIcon.tintColor = Color.danger
            statusLabel.textColor = Color.danger
            statusLabel.text = "Shiny locked in \(game.displayName)"
            statusRow.isHidden = false
        }
        else if (isBeingHunted) {
            statusIcon.image = UIImage.makeSymbol("scope", pointSize: 11, weight: .bold)
            statusIcon.tintColor = Color.textTertiary
            statusLabel.textColor = Color.textTertiary
            statusLabel.text = "In a hunt"
            statusRow.isHidden = false
        }
        else {
            statusRow.isHidden = true
        }
        addToCurrentHuntButton.setImage(UIImage.makeSymbol(isBeingHunted ? "checkmark" : "plus", pointSize: 16, weight: .bold), for: .normal)
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
