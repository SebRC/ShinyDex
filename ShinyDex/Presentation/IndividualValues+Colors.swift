import UIKit

extension IndividualValues {
    fileprivate static let lowColor = Color.danger
    fileprivate static let middleColor = Color.accent
    fileprivate static let highColor = Color.success

    static func getColor(for value: Int) -> UIColor {
        let fraction = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
        if (fraction < 0.5) {
            return lowColor.blended(with: middleColor, fraction: fraction * 2)
        }
        return middleColor.blended(with: highColor, fraction: (fraction - 0.5) * 2)
    }

    func makeColoredSummary(unknownColor: UIColor) -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString(string: summary, attributes: [.foregroundColor: unknownColor]) }
        let separator = NSAttributedString(string: " / ", attributes: [.foregroundColor: unknownColor])
        let result = NSMutableAttributedString()
        for (index, value) in values.enumerated() {
            if (index > 0) {
                result.append(separator)
            }
            let text = value.map(String.init) ?? "?"
            result.append(NSAttributedString(string: text, attributes: [.foregroundColor: value.map(IndividualValues.getColor(for:)) ?? unknownColor]))
        }
        return result
    }
}

extension UIColor {
    func blended(with other: UIColor, fraction: CGFloat) -> UIColor {
        let clampedFraction = min(max(fraction, 0), 1)
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (otherRed, otherGreen, otherBlue, otherAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        other.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: &otherAlpha)
        return UIColor(red: red + (otherRed - red) * clampedFraction,
                       green: green + (otherGreen - green) * clampedFraction,
                       blue: blue + (otherBlue - blue) * clampedFraction,
                       alpha: alpha + (otherAlpha - alpha) * clampedFraction)
    }
}
