import UIKit

final class LuckRow: UIControl {
    fileprivate let onTap: (() -> Void)?

    init(title: String, luck: CatchStatistics.Luck, isEmphasized: Bool = false, onTap: (() -> Void)? = nil) {
        self.onTap = onTap
        super.init(frame: .zero)
        let expected = LuckRow.formatOneDecimal(luck.expectedShinies)
        let difference = Double(luck.foundCount) - luck.expectedShinies
        let isLucky = difference >= 0

        let titleLabel = UILabel(style: .subheadline, weight: .semibold, color: isEmphasized ? Color.accent : Color.textPrimary)
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        let comparisonLabel = UILabel(style: .footnote, color: Color.textSecondary)
        comparisonLabel.font = UIFont.make(.footnote, weight: .regular, monospacedDigits: true)
        comparisonLabel.text = "\(expected) expected · \(luck.foundCount) found"
        comparisonLabel.adjustsFontSizeToFitWidth = true
        comparisonLabel.minimumScaleFactor = 0.8
        let differenceLabel = UILabel(style: .footnote, weight: .bold, color: isLucky ? Color.success : Color.danger)
        differenceLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        differenceLabel.text = (isLucky ? "+" : "−") + LuckRow.formatOneDecimal(abs(difference))
        differenceLabel.setContentHuggingPriority(.required, for: .horizontal)
        differenceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [titleLabel, comparisonLabel, differenceLabel])
        layout.alignment = .center
        layout.spacing = 12
        layout.isUserInteractionEnabled = false
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 12))
        isAccessibilityElement = true
        accessibilityLabel = "\(title): \(expected) expected, \(luck.foundCount) found, \(isLucky ? "luckier" : "unluckier") than expected"
        if onTap != nil {
            let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
            chevron.tintColor = Color.textQuaternary
            chevron.setContentHuggingPriority(.required, for: .horizontal)
            layout.addArrangedSubview(chevron)
            addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            accessibilityTraits = .button
            accessibilityHint = "Shows these catches."
        }
    }

    fileprivate static func formatOneDecimal(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }

    override var isHighlighted: Bool {
        didSet {
            guard onTap != nil else { return }
            backgroundColor = isHighlighted ? Color.surfaceRaised : .clear
        }
    }

    @objc fileprivate func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
