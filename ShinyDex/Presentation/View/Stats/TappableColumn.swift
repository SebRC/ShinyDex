import UIKit

final class TappableColumn: UIControl {
    fileprivate let onTap: () -> Void

    init(content: UIView, onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
        layer.cornerRadius = 8
        content.isUserInteractionEnabled = false
        content.isAccessibilityElement = false
        addAutoLayoutSubviews(content)
        content.pinEdges(to: self)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = content.accessibilityLabel
        accessibilityHint = "Shows these catches."
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
        onTap()
    }
}
