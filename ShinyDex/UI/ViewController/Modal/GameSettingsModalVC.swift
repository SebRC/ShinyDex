import UIKit

class GameSettingsModalVC: UIViewController, UIAdaptivePresentationControllerDelegate, SegueActivated {
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!
	@IBOutlet weak var scrollView: UIScrollView!
	var pokemon: Pokemon!
	var popupHandler = PopupHandler()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.delegate = self

		presentationController?.delegate = self

		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: gameSettingsContainer.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true
		
		roundViewCorner()
        
        gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)
        gameSettingsContainer.gameButton.setImage(UIImage(named: GamesList.games[pokemon.game]?.coverPokemon ?? "charizard"), for: .normal)
        gameSettingsContainer.gameTitle.text = pokemon.game.rawValue
    }
	
	fileprivate func roundViewCorner() {
		gameSettingsContainer.layer.cornerRadius = CornerRadius.standard
	}

	func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
		performSegue(withIdentifier: "unwindFromGameSettings", sender: self)
	}

	func segueActivated() {
		performSegue(withIdentifier: "applyToAll", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "applyToAll") {
			let destVC = segue.destination as! ApplyToAllVC
			destVC.pokemon = pokemon
			destVC.isFromSettings = false
		}
        else if (segue.identifier == "fromGameSettingsToGameSelector") {
            let destVC = segue.destination as! GameSelectorTVC
            destVC.pokemon = pokemon
            destVC.selectedGame = GamesList.games[pokemon.game]
        }
	}

	@IBAction func showGameSettingsConfirmation(_ unwindSegue: UIStoryboardSegue) {
		popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
	}
    
    @objc fileprivate func gameButtonPressed() {
        performSegue(withIdentifier: "fromGameSettingsToGameSelector", sender: self)
    }
    
    @IBAction func gameSelectedInGameSettings(_ unwindSegue: UIStoryboardSegue) {
        let source = unwindSegue.source as! GameSelectorTVC
        let selectedGame = source.selectedGame!
        let shouldMethodBeReset = !selectedGame.availableMethods.contains(pokemon.huntMethod)
        pokemon.huntMethod = shouldMethodBeReset ? .Encounters : pokemon.huntMethod
        let shouldShinyCharmBeEnabled = selectedGame.isShinyCharmAvailable
        pokemon.isShinyCharmActive = shouldShinyCharmBeEnabled ? pokemon.isShinyCharmActive : false
        pokemon = source.pokemon
        gameSettingsContainer.pokemon = pokemon
        gameSettingsContainer.gameButton.setImage(UIImage(named: selectedGame.coverPokemon), for: .normal)
        gameSettingsContainer.gameTitle.text = pokemon.game.rawValue
        gameSettingsContainer.resolveUIObjectsState()
    }
}
