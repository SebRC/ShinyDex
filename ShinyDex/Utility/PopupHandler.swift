import Foundation
import UIKit

class PopupHandler {
	fileprivate static let visibleDuration: TimeInterval = 2.5
	fileprivate static weak var currentToast: ToastView?

	func showPopup(text: String) {
		guard let window = keyWindow() else { return }

		// Only one toast at a time; a new message replaces the old one instead of stacking on top of it.
		PopupHandler.currentToast?.removeFromSuperview()

		let toast = ToastView(text: text)
		toast.translatesAutoresizingMaskIntoConstraints = false
		window.addSubview(toast)
		NSLayoutConstraint.activate([
			toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
			toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
			toast.leadingAnchor.constraint(greaterThanOrEqualTo: window.layoutMarginsGuide.leadingAnchor),
			toast.trailingAnchor.constraint(lessThanOrEqualTo: window.layoutMarginsGuide.trailingAnchor),
			toast.widthAnchor.constraint(lessThanOrEqualToConstant: 500)
		])
		PopupHandler.currentToast = toast

		window.layoutIfNeeded()
		let hiddenTransform = CGAffineTransform(translationX: 0, y: -(toast.frame.maxY + 20))
		let reduceMotion = UIAccessibility.isReduceMotionEnabled
		toast.alpha = 0
		toast.transform = reduceMotion ? .identity : hiddenTransform

		UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [.allowUserInteraction]) {
			toast.alpha = 1
			toast.transform = .identity
		}
		UIAccessibility.post(notification: .announcement, argument: text)

		DispatchQueue.main.asyncAfter(deadline: .now() + PopupHandler.visibleDuration) { [weak toast] in
			guard let toast = toast else { return }
			UIView.animate(withDuration: 0.3, animations: {
				toast.alpha = 0
				toast.transform = reduceMotion ? .identity : hiddenTransform
			}, completion: { _ in
				toast.removeFromSuperview()
			})
		}
	}

	fileprivate func keyWindow() -> UIWindow? {
		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
}
