import UIKit

/// Central place for haptic feedback so every screen uses the same feel for the same kind of action.
enum Haptics {
	static func tap() {
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
	}

	static func bulk() {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
	}

	static func success() {
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	static func warning() {
		UINotificationFeedbackGenerator().notificationOccurred(.warning)
	}
}
