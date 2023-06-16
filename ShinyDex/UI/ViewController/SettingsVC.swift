import UIKit

class SettingsVC: UIViewController, SegueActivated {
	var colorService = ColorService()
	var popupHandler = PopupHandler()
	var pokemon: Pokemon!

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!

	override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true

		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.delegate = self
        gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)
        gameSettingsContainer.gameButton.setImage(UIImage(named: GamesList.games[Games.Red]!.coverPokemon), for: .normal)
        gameSettingsContainer.gameTitle.text = pokemon.game.rawValue

		setUIColors()
		setFonts()
		roundCorners()
    }
	
	fileprivate func setUIColors() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
		]
		
		navigationController?.navigationBar.barTintColor = colorService.getPrimaryColor()
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
		
		view.backgroundColor = colorService.getSecondaryColor()
	}
	
	fileprivate func setFonts() {
		setAttributedFonts()
	}
	
	fileprivate func setAttributedFonts() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func roundCorners() {
		gameSettingsContainer.layer.cornerRadius = CornerRadius.standard
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "applyToAll") {
			let destVC = segue.destination as! ApplyToAllVC
			destVC.pokemon = pokemon
			destVC.isFromSettings = true
		}
        else if (segue.identifier == "toGameSelector") {
            let destVC = segue.destination as! GameSelectorTVC
            destVC.pokemon = pokemon
            destVC.selectedGame = GamesList.games[pokemon.game]
        }
	}
	
    @objc fileprivate func gameButtonPressed() {
        performSegue(withIdentifier: "toGameSelector", sender: self)
    }
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue) {
		setUIColors()
		gameSettingsContainer.setUIColors()
		gameSettingsContainer.setCellColors()
		setFonts()
	}

	func segueActivated() {
		performSegue(withIdentifier: "applyToAll", sender: self)
	}
	@IBAction func showSettingsConfirmation(_ unwindSegue: UIStoryboardSegue) {
		popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
	}
    
    @IBAction func gameSelected(_ unwindSegue: UIStoryboardSegue) {
        let source = unwindSegue.source as! GameSelectorTVC
        let selectedGame = source.selectedGame!
        gameSettingsContainer.updateUI(updatedPokemon: source.pokemon, coverPokemon: selectedGame.coverPokemon)
    }
}
