import UIKit

class HuntPickerCell: UITableViewCell {
    static let reuseIdentifier = "huntPickerCell"

    let nameLabel = UILabel(fontSize: 17, weight: .semibold, lines: 2)
    let subtitleLabel = UILabel(fontSize: 15, color: Color.Grey400)
    let iconImageView = UIImageView()
    fileprivate var imageSizeConstraints = [NSLayoutConstraint]()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.Grey800
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.Grey700
        selectedBackgroundView = selectedBackground
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.magnificationFilter = .nearest
        iconImageView.isAccessibilityElement = false

        let labels = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [iconImageView, labels])
        row.alignment = .center
        row.spacing = 12

        contentView.addAutoLayoutSubviews(row)
        imageSizeConstraints = [
            iconImageView.widthAnchor.constraint(equalToConstant: 56),
            iconImageView.heightAnchor.constraint(equalToConstant: 56)
        ]
        NSLayoutConstraint.activate(imageSizeConstraints + [
            row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: -6),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(hunt: HuntSummary) {
        nameLabel.text = hunt.name
        subtitleLabel.text = HuntHeaderView.formatEncounters(hunt.totalEncounters, pokemonCount: hunt.members.count)
        iconImageView.image = hunt.members.first.flatMap { PokemonSprites.makeImage(pokemonName: $0.name) }
        accessibilityLabel = "\(hunt.name), \(subtitleLabel.text ?? "")"
    }
}
