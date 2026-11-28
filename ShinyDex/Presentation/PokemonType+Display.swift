import UIKit

extension PokemonType {
    var icon: UIImage? {
        return UIImage(named: String(describing: self))?.withRenderingMode(.alwaysTemplate)
    }

    var color: UIColor {
        return MoveTypes.colors[name] ?? Color.inactive
    }

    static func formatList(_ types: [PokemonType]) -> String {
        return types.map { $0.name }.joined(separator: " / ")
    }
}

final class TypeBadge: UIView {
    static let height: CGFloat = 26
    static let iconSize: CGFloat = 14

    fileprivate let label = UILabel(style: .caption1, weight: .bold, color: Color.textPrimary)

    init(type: PokemonType, text: String? = nil, isFaded: Bool = false) {
        super.init(frame: .zero)
        layer.cornerRadius = CornerRadius.capsule(height: TypeBadge.height)
        backgroundColor = isFaded ? .clear : type.color.withAlphaComponent(0.85)
        layer.borderWidth = isFaded ? 1 : 0
        layer.borderColor = type.color.withAlphaComponent(0.5).cgColor
        label.text = text ?? type.name
        label.textColor = isFaded ? Color.textTertiary : .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        let icon = UIImageView(image: type.icon)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = isFaded ? type.color : .white
        let content = UIStackView(arrangedSubviews: [icon, label])
        content.spacing = Spacing.extraSmall
        content.alignment = .center
        addAutoLayoutSubviews(content)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: TypeBadge.iconSize),
            icon.heightAnchor.constraint(equalToConstant: TypeBadge.iconSize),
            content.centerXAnchor.constraint(equalTo: centerXAnchor),
            content.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Spacing.small),
            content.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        heightAnchor.constraint(greaterThanOrEqualToConstant: TypeBadge.height).isActive = true
        isAccessibilityElement = true
        accessibilityLabel = label.text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TeamMember {
    var spriteImage: UIImage? {
        return PokemonSprites.makeImage(pokemonName: battler.pokemonName, formId: battler.formId)
    }

    var title: String {
        return battler.nickname ?? PokemonSprites.makeTitle(pokemonName: battler.pokemonName, formName: battler.formName)
    }

    var summary: String {
        let moves = attackingTypes.isEmpty ? "No damaging moves logged" : "Moves: \(attackingTypes.map { $0.name }.joined(separator: ", "))"
        return [PokemonType.formatList(types), "Readiness \(battler.readiness)", moves].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    func makeContentConfiguration(spriteSide: CGFloat) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.subtitleCell()
        content.image = spriteImage
        content.imageProperties.maximumSize = CGSize(width: spriteSide, height: spriteSide)
        content.imageProperties.reservedLayoutSize = CGSize(width: spriteSide, height: spriteSide)
        content.text = title
        content.textProperties.font = UIFont.make(.body, weight: .semibold)
        content.textProperties.color = Color.textPrimary
        content.secondaryText = summary
        content.secondaryTextProperties.font = UIFont.make(.footnote)
        content.secondaryTextProperties.color = Color.textTertiary
        return content
    }
}
