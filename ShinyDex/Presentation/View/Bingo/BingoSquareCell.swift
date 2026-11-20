import UIKit

class BingoSquareCell: UICollectionViewCell {
    static let reuseIdentifier = "bingoSquareCell"

    fileprivate let spriteView = UIImageView()
    fileprivate let addIcon = UIImageView(image: UIImage.makeSymbol("plus", pointSize: 20, weight: .semibold))
    fileprivate let obtainedBadge = UIImageView(image: UIImage.makeSymbol("checkmark.circle.fill", pointSize: 16, weight: .bold))
    fileprivate let linkableBadge = UIImageView(image: UIImage.makeSymbol("link.circle.fill", pointSize: 16, weight: .bold))

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = CornerRadius.standard
        contentView.layer.borderWidth = 2
        contentView.clipsToBounds = true
        spriteView.contentMode = .scaleAspectFit
        spriteView.layer.magnificationFilter = .nearest
        addIcon.tintColor = Color.Grey600
        addIcon.contentMode = .center
        obtainedBadge.tintColor = Color.Orange500
        linkableBadge.tintColor = Color.Grey400
        contentView.addAutoLayoutSubviews(spriteView, addIcon, obtainedBadge, linkableBadge)
        spriteView.pinEdges(to: contentView, insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        NSLayoutConstraint.activate([
            addIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            obtainedBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            obtainedBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            linkableBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            linkableBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(cell: BingoCellDetails) {
        let isObtained = cell.isObtained
        spriteView.image = cell.pokemonName.flatMap { PokemonSprites.makeImage(pokemonName: $0, formId: cell.formId) }
        spriteView.alpha = isObtained ? 1 : 0.4
        spriteView.isHidden = !cell.isFilled
        addIcon.isHidden = cell.isFilled
        obtainedBadge.isHidden = !isObtained
        linkableBadge.isHidden = isObtained || cell.linkableCatchCount == 0
        contentView.backgroundColor = cell.isInCompletedLine ? Color.Orange900 : Color.Grey800
        contentView.layer.borderColor = (isObtained ? Color.Orange500 : Color.Grey700).cgColor
        accessibilityLabel = makeAccessibilityLabel(for: cell)
        accessibilityTraits = .button
    }

    fileprivate func makeAccessibilityLabel(for cell: BingoCellDetails) -> String {
        guard cell.isFilled else { return "Empty square, add Pokémon" }
        let name = cell.pokemonName.map { PokemonSprites.makeTitle(pokemonName: $0, formName: cell.formName) } ?? "Unknown Pokémon"
        if (cell.isObtained) {
            return "\(name), caught"
        }
        return cell.linkableCatchCount > 0 ? "\(name), not linked, catches available to link" : "\(name), not caught yet"
    }
}
