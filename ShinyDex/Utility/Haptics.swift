import UIKit

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
