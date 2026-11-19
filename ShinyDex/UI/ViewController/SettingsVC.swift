import UIKit

/// `SettingsVC` uses it for the global settings and `GameSettingsModalVC` for a single Pokémon.
class GameSettingsHostVC: UIViewController {
	let scrollView = UIScrollView()
	let gameSettingsContainer = GameSettingsContainer()
	let popupHandler = PopupHandler()
	let pokemonService = PokemonService()
	var pokemon: Pokemon

	init(pokemon: Pokemon) {
		self.pokemon = pokemon
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Color.Grey900
		navigationItem.largeTitleDisplayMode = .never

		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.setGame(coverPokemon: GamesList.games[pokemon.game]?.coverPokemon ?? "charizard")
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

	@objc fileprivate func gameButtonPressed() {
		let selector = GameSelector.make(pokemon: pokemon, selectedGame: GamesList.games[pokemon.game]) { [weak self] game in
			guard let self = self else { return }
			self.gameSettingsContainer.updateUI(updatedPokemon: self.pokemon, coverPokemon: game.coverPokemon)
		}
		navigationController?.pushViewController(selector, animated: true)
	}

	/// Overwrites every Pokémon's game, method and charm, so it gets a confirmation with a destructive button.
	fileprivate func confirmApplyToAll() {
		presentDestructiveConfirmation(title: "Apply to all Pokémon?",
									   message: "Every Pokémon will use \(pokemon.game.displayName) and these hunt settings. Their current settings will be replaced.",
									   destructiveTitle: "Apply to All") { [weak self] in
			guard let self = self else { return }
			self.pokemonService.applyToAll(pokemon: self.pokemon, allPokemon: self.pokemonService.getAll())
			self.popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
		}
	}
}

class SettingsVC: GameSettingsHostVC {
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Settings"
	}
}
