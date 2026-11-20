import UIKit

final class LuckyDateRow: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, title: String, count: Int) {
        super.init(frame: .zero)
        let rankLabel = UILabel(fontSize: 13, weight: .bold, color: rank == 1 ? Color.Orange500 : Color.Grey500)
        rankLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        rankLabel.text = "#\(rank)"
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        let titleLabel = UILabel(fontSize: 15, weight: .medium)
        titleLabel.text = title
        let countLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey300)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        countLabel.text = "\(count) shinies"
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.Grey500
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
            backgroundColor = isHighlighted ? Color.Grey700 : .clear
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
