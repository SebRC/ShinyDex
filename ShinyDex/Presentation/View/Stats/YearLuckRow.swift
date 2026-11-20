import UIKit

final class YearLuckRow: UIControl {
    var onTap: (() -> Void)?

    init(luck: CatchStatistics.YearLuck) {
        super.init(frame: .zero)
        let expected = YearLuckRow.formatOneDecimal(luck.expectedShinies)
        let difference = Double(luck.foundCount) - luck.expectedShinies
        let isLucky = difference >= 0

        let yearLabel = UILabel(fontSize: 15, weight: .semibold)
        yearLabel.text = String(luck.year)
        yearLabel.setContentHuggingPriority(.required, for: .horizontal)
        let comparisonLabel = UILabel(fontSize: 13, color: Color.Grey300)
        comparisonLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        comparisonLabel.text = "\(expected) expected · \(luck.foundCount) found"
        comparisonLabel.adjustsFontSizeToFitWidth = true
        comparisonLabel.minimumScaleFactor = 0.8
        let differenceLabel = UILabel(fontSize: 13, weight: .bold, color: isLucky ? Color.Success400 : Color.Danger300)
        differenceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        differenceLabel.text = (isLucky ? "+" : "−") + YearLuckRow.formatOneDecimal(abs(difference))
        differenceLabel.setContentHuggingPriority(.required, for: .horizontal)
        differenceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.Grey500
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [yearLabel, comparisonLabel, differenceLabel, chevron])
        layout.alignment = .center
        layout.spacing = 12
        layout.isUserInteractionEnabled = false
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 12))
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(luck.year): \(expected) expected, \(luck.foundCount) found, \(isLucky ? "luckier" : "unluckier") than expected"
        accessibilityHint = "Shows the catches from this year."
    }

    fileprivate static func formatOneDecimal(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }

    override var isHighlighted: Bool {
        didSet {
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
