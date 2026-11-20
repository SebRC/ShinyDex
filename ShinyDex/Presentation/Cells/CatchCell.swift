import UIKit

class CatchCell: UITableViewCell {
    static let reuseIdentifier = "catchCell"
    static let height: CGFloat = 72

    fileprivate let sprite = UIImageView()
    fileprivate let titleLabel = UILabel(fontSize: 17, weight: .semibold)
    fileprivate let subtitleLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate let ballImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.Grey800
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.Grey700
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

    func configure(pokemonName: String, title: String, subtitle: String, ball: String, isFailed: Bool = false) {
        sprite.image = UIImage(named: pokemonName.lowercased())
        sprite.alpha = isFailed ? 0.55 : 1
        titleLabel.text = title
        titleLabel.textColor = isFailed ? Color.Grey300 : Color.Grey200
        subtitleLabel.text = subtitle
        ballImageView.image = isFailed ? UIImage.makeSymbol("wind", pointSize: 20, weight: .semibold) : UIImage(named: ball)
        ballImageView.tintColor = Color.Grey500
        ballImageView.contentMode = isFailed ? .center : .scaleAspectFit
        accessibilityLabel = "\(title), \(subtitle)"
    }
}
