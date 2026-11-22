import UIKit

final class CatchHeroCell: UITableViewCell {
    static let reuseIdentifier = "catchHeroCell"

    fileprivate static let spriteSide: CGFloat = 170
    fileprivate static let glowSide: CGFloat = 280
    fileprivate let glowView = GlowView(intensity: 0.35)
    fileprivate let spriteView = PokemonSpriteView()
    fileprivate let badgeLabel = UILabel(style: .footnote, weight: .bold, color: Color.background)
    fileprivate let badge = UIView()
    fileprivate let badgeIcon = UIImageView()
    fileprivate let nameLabel = UILabel(style: .title1, weight: .bold, color: Color.textPrimary)
    fileprivate let speciesLabel = UILabel(style: .body, weight: .semibold, color: Color.textSecondary)
    fileprivate let dateLabel = UILabel(style: .subheadline, color: Color.textTertiary)
    fileprivate let positionLabel = UILabel(style: .footnote, weight: .semibold, color: Color.accent)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none


        badge.layer.cornerRadius = CornerRadius.capsule(height: 22)
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

    func playSpriteAnimationOnce() {
        spriteView.playAnimationOnce()
    }

    func configure(pokemonName: String, spriteAssetName: String, nickname: String?, gender: Gender?, dateText: String, positionText: String?, isFailed: Bool) {
        badge.backgroundColor = isFailed ? Color.inactive : Color.accent
        badgeLabel.text = isFailed ? "GOT AWAY" : "SHINY"
        badgeLabel.textColor = isFailed ? Color.textPrimary : Color.background
        badgeIcon.image = UIImage(systemName: isFailed ? "wind" : PokemonCell.logCatchSymbol)
        badgeIcon.tintColor = badgeLabel.textColor
        glowView.isHidden = isFailed
        spriteView.setPokemon(named: spriteAssetName)
        let name = NSMutableAttributedString(string: nickname ?? pokemonName, attributes: [.font: nameLabel.font as Any, .foregroundColor: nameLabel.textColor as Any])
        if let gender = gender, gender.symbol != nil {
            name.append(NSAttributedString(string: " "))
            name.append(gender.makeColoredLabel(font: nameLabel.font))
        }
        nameLabel.attributedText = name
        speciesLabel.text = pokemonName
        speciesLabel.isHidden = nickname == nil
        dateLabel.text = dateText
        positionLabel.text = positionText
        positionLabel.isHidden = positionText == nil
        accessibilityLabel = [nickname, isFailed ? "Shiny \(pokemonName) that got away" : "Shiny \(pokemonName)", dateText, positionText].compactMap { $0 }.joined(separator: ", ")
    }
}
