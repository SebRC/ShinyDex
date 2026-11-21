import UIKit

class CatchCell: UITableViewCell {
    static let reuseIdentifier = "catchCell"
    static let height: CGFloat = 72

    fileprivate let sprite = UIImageView()
    fileprivate let titleLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let subtitleLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let ballImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        for imageView in [sprite, ballImageView] {
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
            imageView.isAccessibilityElement = false
        }

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [sprite, labels, ballImageView])
        row.alignment = .center
        row.spacing = 10
        contentView.addAutoLayoutSubviews(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            row.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sprite.widthAnchor.constraint(equalToConstant: 60),
            sprite.heightAnchor.constraint(equalToConstant: 60),
            ballImageView.widthAnchor.constraint(equalToConstant: 36),
            ballImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(pokemonName: String, formId: String? = nil, title: String, subtitle: String, ball: String, isFailed: Bool = false) {
        sprite.image = PokemonSprites.makeImage(pokemonName: pokemonName, formId: formId)
        sprite.alpha = isFailed ? 0.55 : 1
        titleLabel.text = title
        titleLabel.textColor = isFailed ? Color.textSecondary : Color.textPrimary
        subtitleLabel.text = subtitle
        ballImageView.image = isFailed ? UIImage.makeSymbol("wind", pointSize: 20, weight: .semibold) : UIImage(named: ball)
        ballImageView.tintColor = Color.textQuaternary
        ballImageView.contentMode = isFailed ? .center : .scaleAspectFit
        accessibilityLabel = "\(title), \(subtitle)"
    }
}
