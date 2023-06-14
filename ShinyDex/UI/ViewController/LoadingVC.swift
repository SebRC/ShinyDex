import UIKit

class LoadingVC: UIViewController {
	@IBOutlet weak var loadingLabel: UILabel!
	var pokemonService = PokemonService()
	var moveService = MoveService()
	var colorService = ColorService()
	var isFirstTimeUser: Bool!
	var loadingGifData: Data?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		resolveUserStatus()
		hideNavigationBar()


		view.backgroundColor = colorService.getSecondaryColor()
		loadingLabel.textColor = colorService.getTertiaryColor()
		
		if (isFirstTimeUser) {
			proceedAsNewUser()
		}
		else {
			proceedAsExistingUser()
		}
    }
	
	fileprivate func resolveUserStatus() {
		let allPokemon = pokemonService.getAll()
		isFirstTimeUser = allPokemon.count == 0
	}
	
	fileprivate func hideNavigationBar() {
		navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func proceedAsNewUser()	{
		pokemonService.populateDatabase()
		moveService.populateDatabase()
		performSegue(withIdentifier: "load", sender: self)
	}
	
	fileprivate func proceedAsExistingUser() {
		performSegue(withIdentifier: "load", sender: self)
	}
}
