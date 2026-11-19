import UIKit

class LoadingVC: UIViewController {
	fileprivate let loadingLabel = UILabel(fontSize: 35, color: Color.Orange500)
	fileprivate let activityIndicator = UIActivityIndicatorView(style: .large)
	var pokemonService = PokemonService()
	var moveService = MoveService()
	var catchService = CatchService()
	var txtReader = TxtReader()

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
		prepareData()
		showMenu()
	}

	fileprivate func prepareData() {
		let allPokemon = pokemonService.getAll()
		if (isFirstTimeUser(allPokemon: allPokemon)) {
			pokemonService.populateDatabase()
			moveService.populateDatabase()
			return
		}
		if (needsMigration(allPokemon: allPokemon)) {
			pokemonService.migrate()
		}
		catchService.backfillIfNeeded()
	}

	fileprivate func isFirstTimeUser(allPokemon: [Pokemon]) -> Bool {
		return allPokemon.count == 0
	}

	fileprivate func needsMigration(allPokemon: [Pokemon]) -> Bool {
		let names = txtReader.readFile(textFile: "allGens")
		return allPokemon.count != names.count
	}

	/// The loading screen is replaced rather than pushed, so there's nothing to go back to.
	fileprivate func showMenu() {
		guard let navigationController = navigationController else { return }
		navigationController.isNavigationBarHidden = false
		let menu = MenuTVC()
		UIView.transition(with: navigationController.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
			navigationController.setViewControllers([menu], animated: false)
		})
	}
}
