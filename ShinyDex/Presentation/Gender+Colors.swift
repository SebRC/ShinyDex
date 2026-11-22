import UIKit

extension Gender {
    var color: UIColor {
        switch self {
        case .male: return Color.male
        case .female: return Color.female
        case .genderless: return Color.textTertiary
        }
    }

    func makeColoredLabel(font: UIFont, nameColor: UIColor? = nil) -> NSAttributedString {
        let text = NSMutableAttributedString()
        if let symbol = symbol {
            text.append(NSAttributedString(string: symbol, attributes: [.font: font, .foregroundColor: color]))
        }
        if let nameColor = nameColor {
            text.append(NSAttributedString(string: symbol == nil ? name : " \(name)", attributes: [.font: font, .foregroundColor: nameColor]))
        }
        return text
    }

    func makeSymbolImage(style: TypeStyle) -> UIImage? {
        guard let symbol = symbol else {
            return UIImage.makeSymbol("circle.slash", pointSize: UIFont.make(style).pointSize, weight: .semibold)?.withTintColor(color, renderingMode: .alwaysOriginal)
        }
        let text = NSAttributedString(string: symbol, attributes: [.font: UIFont.make(style, weight: .bold), .foregroundColor: color])
        return UIGraphicsImageRenderer(size: text.size()).image { _ in text.draw(at: .zero) }
    }
}
