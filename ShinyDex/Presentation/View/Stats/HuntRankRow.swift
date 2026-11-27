import UIKit

final class HuntRankRow: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, hunt: CatchSummary, detail: String? = nil, valueDetail: String? = nil, valueDetailColor: UIColor = Color.textTertiary) {
        super.init(frame: .zero)
        let rankLabel = UILabel(style: .footnote, weight: .bold, color: rank == 1 ? Color.accent : Color.textQuaternary)
        rankLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        rankLabel.text = "#\(rank)"
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        let sprite = UIImageView(image: hunt.spriteImage)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.alpha = hunt.isFailed ? 0.55 : 1
        let nameLabel = UILabel(style: .subheadline, weight: .medium)
        nameLabel.text = hunt.nickname ?? hunt.speciesTitle
        let detailLabel = UILabel(style: .caption1, color: Color.textTertiary)
        detailLabel.text = detail ?? [hunt.isFailed ? "Got away" : hunt.game.displayName, hunt.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 1
        let encountersLabel = UILabel(style: .footnote, weight: .semibold, color: Color.textSecondary)
        encountersLabel.font = UIFont.make(.footnote, weight: .semibold, monospacedDigits: true)
        encountersLabel.text = hunt.encounters.grouped
        encountersLabel.setContentHuggingPriority(.required, for: .horizontal)
        encountersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let valueDetailLabel = UILabel(style: .caption1, weight: .semibold, color: valueDetailColor)
        valueDetailLabel.font = UIFont.make(.caption1, weight: .semibold, monospacedDigits: true)
        valueDetailLabel.text = valueDetail
        valueDetailLabel.isHidden = valueDetail == nil
        let values = UIStackView(arrangedSubviews: [encountersLabel, valueDetailLabel])
        values.axis = .vertical
        values.alignment = .trailing
        values.spacing = 1
        values.setContentHuggingPriority(.required, for: .horizontal)
        values.setContentCompressionResistancePriority(.required, for: .horizontal)
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.textQuaternary
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [rankLabel, sprite, labels, values, chevron])
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
        accessibilityLabel = ["Number \(rank): \(nameLabel.text ?? "")", "\(hunt.encounters.grouped) encounters", valueDetail, detailLabel.text].compactMap { $0 }.joined(separator: ", ")
        accessibilityHint = "Shows this catch."
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.surfaceRaised : .clear
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }
}
