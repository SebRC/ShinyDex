import UIKit

/// Central place for haptic feedback so every screen uses the same feel for the same kind of action.
enum Haptics {
	/// Encounter counted up or down.
	static func tap() {
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
	}

	/// Several encounters counted at once, like incrementing a whole hunt.
	static func bulk() {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
	}

	/// Something worth celebrating, like logging a shiny.
	static func success() {
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}

	/// A destructive action went through.
	static func warning() {
		UINotificationFeedbackGenerator().notificationOccurred(.warning)
	}
}
