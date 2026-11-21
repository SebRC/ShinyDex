import UIKit

enum TypeStyle {
    case caption2
    case caption1
    case footnote
    case subheadline
    case body
    case title3
    case title2
    case title1
    case largeTitle
    case display
    case hero

    fileprivate static let largestScale: CGFloat = 1.35

    var pointSize: CGFloat {
        switch self {
        case .caption2: return 11
        case .caption1: return 12
        case .footnote: return 13
        case .subheadline: return 15
        case .body: return 17
        case .title3: return 20
        case .title2: return 22
        case .title1: return 28
        case .largeTitle: return 34
        case .display: return 44
        case .hero: return 56
        }
    }

    fileprivate var metricsStyle: UIFont.TextStyle {
        switch self {
        case .caption2: return .caption2
        case .caption1: return .caption1
        case .footnote: return .footnote
        case .subheadline: return .subheadline
        case .body: return .body
        case .title3: return .title3
        case .title2: return .title2
        case .title1: return .title1
        case .largeTitle, .display, .hero: return .largeTitle
        }
    }

    func makeFont(weight: UIFont.Weight = .regular, monospacedDigits: Bool = false) -> UIFont {
        let font = monospacedDigits
            ? UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: weight)
            : UIFont.systemFont(ofSize: pointSize, weight: weight)
        return UIFontMetrics(forTextStyle: metricsStyle).scaledFont(for: font, maximumPointSize: pointSize * TypeStyle.largestScale)
    }
}

extension UIFont {
    static func make(_ style: TypeStyle, weight: UIFont.Weight = .regular, monospacedDigits: Bool = false) -> UIFont {
        return style.makeFont(weight: weight, monospacedDigits: monospacedDigits)
    }
}
