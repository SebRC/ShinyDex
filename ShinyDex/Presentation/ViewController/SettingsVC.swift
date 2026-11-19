import UIKit

class GameSettingsHostVC: UIViewController {
	let scrollView = UIScrollView()
	let gameSettingsContainer = GameSettingsContainer()
	let popupHandler = PopupHandler()
	fileprivate let container: AppContainer
	fileprivate let pokemonNumber: Int?
	fileprivate let encounters: Int

	init(container: AppContainer, pokemon: PokemonDetails?) {
		self.container = container
		pokemonNumber = pokemon?.number
		encounters = pokemon?.encounters ?? 0
		gameSettingsContainer.settings = pokemon?.settings ?? HuntSettings(game: .Red, generation: 1, huntMethod: .Encounters, isShinyCharmActive: false)
		gameSettingsContainer.subjectName = pokemon?.name
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Color.Grey900
		navigationItem.largeTitleDisplayMode = .never

		gameSettingsContainer.preview = { [container, encounters] settings in
			container.previewHuntSettings.handle(PreviewHuntSettingsQuery(settings: settings, encounters: encounters))
		}
		gameSettingsContainer.onSettingsChanged = { [weak self] settings in
			self?.save(settings)
		}
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.setGame(coverPokemon: GamesList.games[gameSettingsContainer.settings.game]?.coverPokemon ?? "charizard")
		gameSettingsContainer.onApplyToAll = { [weak self] in self?.confirmApplyToAll() }
		gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)

		view.addAutoLayoutSubviews(scrollView)
		scrollView.addAutoLayoutSubviews(gameSettingsContainer)
		scrollView.pinEdges(to: view)
		let content = scrollView.contentLayoutGuide
		NSLayoutConstraint.activate([
			gameSettingsContainer.topAnchor.constraint(equalTo: content.topAnchor, constant: 8),
			gameSettingsContainer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -8),
			gameSettingsContainer.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 8),
			gameSettingsContainer.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -8)
		])
	}

	fileprivate func save(_ settings: HuntSettings) {
		guard let number = pokemonNumber else { return }
		container.saveHuntSettings.handle(SaveHuntSettingsCommand(number: number, settings: settings))
	}

	@objc fileprivate func gameButtonPressed() {
		let selector = GameSelector.make(selectedGame: gameSettingsContainer.settings.game) { [weak self] game in
			guard let self = self else { return }
			let preview = self.container.previewHuntSettings.handle(PreviewHuntSettingsQuery(settings: self.gameSettingsContainer.settings, encounters: self.encounters, selectingGame: game))
			self.save(preview.settings)
			self.gameSettingsContainer.updateUI(updatedSettings: preview.settings, coverPokemon: GamesList.games[game]?.coverPokemon ?? "charizard")
		}
		navigationController?.pushViewController(selector, animated: true)
	}

	fileprivate func confirmApplyToAll() {
		let settings = gameSettingsContainer.settings!
		presentDestructiveConfirmation(title: "Apply to all Pokémon?",
									   message: "Every Pokémon will use \(settings.game.displayName) and these hunt settings. Their current settings will be replaced.",
									   destructiveTitle: "Apply to All") { [weak self] in
			guard let self = self else { return }
			self.container.applyHuntSettingsToAll.handle(ApplyHuntSettingsToAllCommand(settings: self.gameSettingsContainer.settings))
			self.popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
		}
	}
}

class SettingsVC: GameSettingsHostVC {
	init(container: AppContainer) {
		super.init(container: container, pokemon: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Settings"
	}
}
