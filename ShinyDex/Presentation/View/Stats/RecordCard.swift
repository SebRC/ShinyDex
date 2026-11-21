import UIKit

final class RecordCard: UIControl {
    var onTap: (() -> Void)?

    init(title: String, symbol: String, caught: CatchSummary) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let symbolView = UIImageView(image: UIImage.makeSymbol(symbol, pointSize: 12, weight: .bold))
        symbolView.tintColor = Color.accent
        let titleLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
        titleLabel.text = title.uppercased()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        let titleRow = UIStackView(arrangedSubviews: [symbolView, titleLabel])
        titleRow.spacing = 5
        titleRow.alignment = .center

        let sprite = UIImageView(image: caught.spriteImage)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        let encountersLabel = UILabel(style: .title2, weight: .bold, color: Color.textPrimary)
        encountersLabel.font = UIFont.make(.title2, weight: .bold, monospacedDigits: true)
        encountersLabel.text = caught.encounters.grouped
        encountersLabel.adjustsFontSizeToFitWidth = true
        encountersLabel.minimumScaleFactor = 0.6
        let detailLabel = UILabel(style: .caption1, color: Color.textTertiary)
        detailLabel.text = [caught.speciesTitle, caught.isFailed ? "got away" : nil, caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.minimumScaleFactor = 0.8

        let stack = UIStackView(arrangedSubviews: [titleRow, sprite, encountersLabel, detailLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.setCustomSpacing(-4, after: sprite)
        stack.isUserInteractionEnabled = false
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64)
        ])
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(title): \(caught.pokemonName), \(caught.encounters) encounters"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }
}
