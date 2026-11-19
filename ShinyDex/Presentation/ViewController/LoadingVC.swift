import UIKit

class LoadingVC: UIViewController {
	fileprivate let loadingLabel = UILabel(fontSize: 35, color: Color.Orange500)
	fileprivate let activityIndicator = UIActivityIndicatorView(style: .large)
	fileprivate let container: AppContainer

	init(container: AppContainer) {
		self.container = container
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.isNavigationBarHidden = true
		view.backgroundColor = Color.Grey900

		loadingLabel.text = "Loading…"
		loadingLabel.textAlignment = .center
		activityIndicator.color = Color.Orange500
		activityIndicator.startAnimating()

		let stack = UIStackView(arrangedSubviews: [activityIndicator, loadingLabel])
		stack.axis = .vertical
		stack.spacing = 16
		view.addAutoLayoutSubviews(stack)
		NSLayoutConstraint.activate([
			stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		container.prepareData.handle(PrepareDataCommand())
		showMenu()
	}

	fileprivate func showMenu() {
		guard let navigationController = navigationController else { return }
		navigationController.isNavigationBarHidden = false
		let menu = MenuTVC(container: container)
		UIView.transition(with: navigationController.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
			navigationController.setViewControllers([menu], animated: false)
		})
	}
}
