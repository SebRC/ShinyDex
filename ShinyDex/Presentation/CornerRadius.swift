import UIKit

enum CornerRadius {
    static let tiny: CGFloat = 3
    static let small: CGFloat = 8
    static let standard: CGFloat = 12
    static let large: CGFloat = 16

    static func capsule(height: CGFloat) -> CGFloat {
        return height / 2
    }
}
