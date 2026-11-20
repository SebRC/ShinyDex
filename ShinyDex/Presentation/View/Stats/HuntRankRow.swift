import UIKit

final class HuntRankRow: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, hunt: CatchSummary) {
        super.init(frame: .zero)
        let rankLabel = UILabel(fontSize: 13, weight: .bold, color: rank == 1 ? Color.Orange500 : Color.Grey500)
        rankLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        rankLabel.text = "#\(rank)"
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        let sprite = UIImageView(image: UIImage(named: hunt.pokemonName.lowercased()))
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.alpha = hunt.isFailed ? 0.55 : 1
        let nameLabel = UILabel(fontSize: 15, weight: .medium)
        nameLabel.text = hunt.nickname ?? hunt.pokemonName
        let detailLabel = UILabel(fontSize: 12, color: Color.Grey400)
        detailLabel.text = [hunt.isFailed ? "Got away" : hunt.game.displayName, hunt.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 1
        let encountersLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey300)
        encountersLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        encountersLabel.text = hunt.encounters.grouped
        encountersLabel.setContentHuggingPriority(.required, for: .horizontal)
        encountersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.Grey500
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [rankLabel, sprite, labels, encountersLabel, chevron])
        layout.alignment = .center
        layout.spacing = 10
        layout.isUserInteractionEnabled = false
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 12))
        NSLayoutConstraint.activate([
            rankLabel.widthAnchor.constraint(equalToConstant: 28),
            sprite.widthAnchor.constraint(equalToConstant: 40),
            sprite.heightAnchor.constraint(equalToConstant: 40)
        ])
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Number \(rank): \(nameLabel.text ?? ""), \(hunt.encounters.grouped) encounters, \(detailLabel.text ?? "")"
        accessibilityHint = "Shows this catch."
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.Grey700 : .clear
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }
}
