import UIKit

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func playBulk() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func playSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func playWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
