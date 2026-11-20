import UIKit

final class LuckRow: UIControl {
    fileprivate let onTap: (() -> Void)?

    init(title: String, luck: CatchStatistics.Luck, isEmphasized: Bool = false, onTap: (() -> Void)? = nil) {
        self.onTap = onTap
        super.init(frame: .zero)
        let expected = LuckRow.formatOneDecimal(luck.expectedShinies)
        let difference = Double(luck.foundCount) - luck.expectedShinies
        let isLucky = difference >= 0

        let titleLabel = UILabel(fontSize: 15, weight: .semibold, color: isEmphasized ? Color.Orange500 : Color.Grey100)
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        let comparisonLabel = UILabel(fontSize: 13, color: Color.Grey300)
        comparisonLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        comparisonLabel.text = "\(expected) expected · \(luck.foundCount) found"
        comparisonLabel.adjustsFontSizeToFitWidth = true
        comparisonLabel.minimumScaleFactor = 0.8
        let differenceLabel = UILabel(fontSize: 13, weight: .bold, color: isLucky ? Color.Success400 : Color.Danger300)
        differenceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
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
            chevron.tintColor = Color.Grey500
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
            backgroundColor = isHighlighted ? Color.Grey700 : .clear
        }
    }

    @objc fileprivate func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
