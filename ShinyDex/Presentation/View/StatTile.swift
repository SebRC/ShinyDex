import UIKit

final class StatTile: UIControl {
    fileprivate let captionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
    fileprivate let valueLabel = UILabel(style: .title1, weight: .bold)
    fileprivate let detailLabel = UILabel(style: .caption1, color: Color.textTertiary, lines: 2)
    fileprivate let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))

    var onTap: (() -> Void)? {
        didSet {
            chevron.isHidden = onTap == nil
            accessibilityTraits = onTap == nil ? .none : .button
        }
    }

    init(caption: String) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        isAccessibilityElement = true

        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.minimumScaleFactor = 0.8
        valueLabel.font = UIFont.make(.title1, weight: .bold, monospacedDigits: true)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        detailLabel.isHidden = true
        chevron.tintColor = Color.textQuaternary
        chevron.isHidden = true
        setCaption(caption)

        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.isUserInteractionEnabled = false
        addAutoLayoutSubviews(stack, chevron)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.medium, left: 14, bottom: Spacing.medium, right: 14))
        NSLayoutConstraint.activate([
            chevron.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.medium),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 68)
        ])
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    convenience init(caption: String, value: String, detail: String? = nil, isValueEmphasized: Bool = false, onTap: (() -> Void)? = nil) {
        self.init(caption: caption)
        setValue(value, isEmphasized: isValueEmphasized)
        setDetail(detail)
        self.onTap = onTap
        chevron.isHidden = onTap == nil
        accessibilityTraits = onTap == nil ? .none : .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            guard onTap != nil else { return }
            backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
        }
    }

    func setCaption(_ caption: String) {
        captionLabel.text = caption.uppercased()
        accessibilityLabel = caption
    }

    func setValue(_ value: String, isEmphasized: Bool = false) {
        valueLabel.font = UIFont.make(.title1, weight: .bold, monospacedDigits: true)
        valueLabel.textColor = isEmphasized ? Color.accent : Color.textPrimary
        valueLabel.numberOfLines = 1
        valueLabel.text = value
        updateAccessibilityValue()
    }

    func setMessage(_ message: String) {
        valueLabel.font = UIFont.make(.subheadline)
        valueLabel.textColor = Color.textSecondary
        valueLabel.numberOfLines = 2
        valueLabel.text = message
        updateAccessibilityValue()
    }

    func setDetail(_ detail: String?, isEmphasized: Bool = false) {
        detailLabel.text = detail
        detailLabel.textColor = isEmphasized ? Color.accent : Color.textTertiary
        detailLabel.font = UIFont.make(.caption1, weight: isEmphasized ? .semibold : .regular)
        detailLabel.isHidden = detail == nil
        updateAccessibilityValue()
    }

    fileprivate func updateAccessibilityValue() {
        accessibilityValue = [valueLabel.text, detailLabel.isHidden ? nil : detailLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    @objc fileprivate func tapped() {
        onTap?()
    }
}
