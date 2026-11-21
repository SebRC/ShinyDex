import UIKit

enum ButtonStyle {
    case primary
    case secondary
    case tinted
    case destructive
    case pill

    fileprivate var colors: (background: UIColor, foreground: UIColor) {
        switch self {
        case .primary, .pill: return (Color.accent, Color.onAccent)
        case .secondary: return (Color.surfaceRaised, Color.textPrimary)
        case .tinted: return (Color.accentSubtle, Color.accent)
        case .destructive: return (Color.danger, Color.textPrimary)
        }
    }
}

enum CounterButtonRole {
    case primary
    case secondary

    fileprivate var tint: UIColor {
        switch self {
        case .primary: return Color.accent
        case .secondary: return Color.textQuaternary
        }
    }
}

extension UIButton {
    static func make(_ style: ButtonStyle, title: String? = nil, symbolName: String? = nil, typeStyle: TypeStyle = .body, symbolSize: CGFloat = 17,
                     cornerRadius: CGFloat = CornerRadius.standard) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        let colors = style.colors
        configuration.baseBackgroundColor = colors.background
        configuration.baseForegroundColor = colors.foreground
        if style == .pill {
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 14)
        }
        else {
            configuration.cornerStyle = .fixed
            configuration.background.cornerRadius = cornerRadius
        }
        configuration.image = symbolName.flatMap { UIImage.makeSymbol($0, pointSize: symbolSize, weight: .bold) }
        configuration.imagePadding = style == .pill ? 4 : 8
        if let title = title {
            var attributedTitle = AttributedString(title)
            attributedTitle.font = UIFont.make(typeStyle, weight: .bold, monospacedDigits: true)
            configuration.attributedTitle = attributedTitle
        }
        let button = UIButton(configuration: configuration)
        button.configurationUpdateHandler = { button in
            var updated = button.configuration
            updated?.baseBackgroundColor = button.isEnabled ? colors.background : Color.surfaceRaised
            updated?.baseForegroundColor = button.isEnabled ? colors.foreground : Color.inactive
            button.configuration = updated
        }
        return button
    }

    func setStyledTitle(_ title: String, typeStyle: TypeStyle) {
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont.make(typeStyle, weight: .bold, monospacedDigits: true)
        configuration?.attributedTitle = attributedTitle
    }

    static func makeCounterButton(symbolName: String, role: CounterButtonRole, pointSize: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage.makeSymbol(symbolName, pointSize: pointSize), for: .normal)
        button.tintColor = role.tint
        return button
    }

    static func makeRoundButton(_ style: ButtonStyle, symbolName: String, diameter: CGFloat, symbolSize: CGFloat = 16) -> UIButton {
        return make(style, symbolName: symbolName, symbolSize: symbolSize, cornerRadius: CornerRadius.capsule(height: diameter))
    }
}
