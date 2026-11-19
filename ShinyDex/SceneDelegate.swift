import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }
		let window = UIWindow(windowScene: windowScene)
		window.overrideUserInterfaceStyle = .dark
		window.backgroundColor = Color.Grey900
		window.tintColor = Color.Orange500
		window.rootViewController = ShinyNavigationController(rootViewController: LoadingVC())
		window.makeKeyAndVisible()
		self.window = window
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}
}
