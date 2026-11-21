import UIKit

final class LuckyDateRow: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, title: String, count: Int) {
        super.init(frame: .zero)
        let rankLabel = UILabel(style: .footnote, weight: .bold, color: rank == 1 ? Color.accent : Color.textQuaternary)
        rankLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        rankLabel.text = "#\(rank)"
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        let titleLabel = UILabel(style: .subheadline, weight: .medium)
        titleLabel.text = title
        let countLabel = UILabel(style: .footnote, weight: .semibold, color: Color.textSecondary)
        countLabel.font = UIFont.make(.footnote, weight: .semibold, monospacedDigits: true)
        countLabel.text = "\(count) shinies"
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.textQuaternary
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [rankLabel, titleLabel, countLabel, chevron])
        layout.alignment = .center
        layout.spacing = 10
        layout.isUserInteractionEnabled = false
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 12))
        rankLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Number \(rank): \(title), \(count) shinies"
        accessibilityHint = "Shows the catches from this date."
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.surfaceRaised : .clear
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
