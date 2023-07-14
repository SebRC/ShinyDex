import UIKit

class LoadingVC: UIViewController {
	@IBOutlet weak var loadingLabel: UILabel!
	var pokemonService = PokemonService()
	var moveService = MoveService()
    var txtReader = TxtReader()
	var loadingGifData: Data?
	
	override func viewDidLoad() {
        super.viewDidLoad()
        //pokemonService.deleteAll()

		hideNavigationBar()

        view.backgroundColor = Color.Grey900
        loadingLabel.textColor = Color.Orange500
        let allPokemon = pokemonService.getAll()
        print("BEFORE IF")
		if (isFirstTimeUser(allPokemon: allPokemon)) {
            print("FIRST TIME USER")
			proceedAsNewUser()
		}
        else if(needsMigration(allPokemon: allPokemon))
        {
            pokemonService.migrate()
            proceedAsExistingUser()
        }
		else {
            print("EXISTING USER")
			proceedAsExistingUser()
		}
    }
	
    fileprivate func isFirstTimeUser(allPokemon: [Pokemon]) -> Bool {
		return allPokemon.count == 0
	}
    
    fileprivate func needsMigration(allPokemon: [Pokemon]) -> Bool {
        let genText = "allGens"
        let names = txtReader.readFile(textFile: genText)
        return allPokemon.count != names.count
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
