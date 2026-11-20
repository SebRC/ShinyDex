import UIKit

final class CatchHeroCell: UITableViewCell {
    static let reuseIdentifier = "catchHeroCell"

    fileprivate static let spriteSide: CGFloat = 170
    fileprivate static let glowSide: CGFloat = 280
    fileprivate let glowView = GlowView(intensity: 0.35)
    fileprivate let spriteView = PokemonSpriteView()
    fileprivate let badgeLabel = UILabel(fontSize: 13, weight: .bold, color: Color.Grey900)
    fileprivate let badge = UIView()
    fileprivate let badgeIcon = UIImageView()
    fileprivate let nameLabel = UILabel(fontSize: 30, weight: .bold, color: Color.Grey100)
    fileprivate let speciesLabel = UILabel(fontSize: 17, weight: .semibold, color: Color.Grey300)
    fileprivate let dateLabel = UILabel(fontSize: 15, color: Color.Grey400)
    fileprivate let positionLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none


        badge.layer.cornerRadius = 11
        badgeIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let badgeContent = UIStackView(arrangedSubviews: [badgeIcon, badgeLabel])
        badgeContent.spacing = 4
        badgeContent.alignment = .center
        badge.addAutoLayoutSubviews(badgeContent)
        badgeContent.pinEdges(to: badge, insets: UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 10))

        nameLabel.textAlignment = .center
        speciesLabel.textAlignment = .center
        dateLabel.textAlignment = .center
        positionLabel.textAlignment = .center

        let text = UIStackView(arrangedSubviews: [badge, nameLabel, speciesLabel, dateLabel, positionLabel])
        text.axis = .vertical
        text.alignment = .center
        text.spacing = 4
        text.setCustomSpacing(8, after: badge)

        contentView.addAutoLayoutSubviews(glowView, spriteView, text)
        // The glow sits fully inside the cell: the inset grouped table clips anything drawn above a cell's top edge.
        NSLayoutConstraint.activate([
            glowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            glowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            glowView.widthAnchor.constraint(equalToConstant: CatchHeroCell.glowSide),
            glowView.heightAnchor.constraint(equalToConstant: CatchHeroCell.glowSide),

            spriteView.centerXAnchor.constraint(equalTo: glowView.centerXAnchor),
            spriteView.centerYAnchor.constraint(equalTo: glowView.centerYAnchor),
            spriteView.widthAnchor.constraint(equalToConstant: CatchHeroCell.spriteSide),
            spriteView.heightAnchor.constraint(equalToConstant: CatchHeroCell.spriteSide),

            text.topAnchor.constraint(equalTo: spriteView.bottomAnchor, constant: 8),
            text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(pokemonName: String, nickname: String?, genderSymbol: String?, dateText: String, positionText: String?, isFailed: Bool) {
        badge.backgroundColor = isFailed ? Color.Grey600 : Color.Orange500
        badgeLabel.text = isFailed ? "GOT AWAY" : "SHINY"
        badgeLabel.textColor = isFailed ? Color.Grey100 : Color.Grey900
        badgeIcon.image = UIImage(systemName: isFailed ? "wind" : PokemonCell.logCatchSymbol)
        badgeIcon.tintColor = badgeLabel.textColor
        glowView.isHidden = isFailed
        spriteView.setPokemon(named: pokemonName)
        nameLabel.text = [nickname ?? pokemonName, genderSymbol].compactMap { $0 }.joined(separator: " ")
        speciesLabel.text = pokemonName
        speciesLabel.isHidden = nickname == nil
        dateLabel.text = dateText
        positionLabel.text = positionText
        positionLabel.isHidden = positionText == nil
        accessibilityLabel = [nickname, isFailed ? "Shiny \(pokemonName) that got away" : "Shiny \(pokemonName)", dateText, positionText].compactMap { $0 }.joined(separator: ", ")
    }
}
