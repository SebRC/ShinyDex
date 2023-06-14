import UIKit

class ApplyToAllVC: UIViewController {
	@IBOutlet weak var confirmationView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var descriptionLabel: UILabel!

	let colorService = ColorService()
	let pokemonService = PokemonService()
	var pokemon: Pokemon!
	var allPokemon = [Pokemon]()
	var isFromSettings = true

	override func viewDidLoad() {
        super.viewDidLoad()
		allPokemon = pokemonService.getAll()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		confirmationView.layer.cornerRadius = CornerRadius.standard
		confirmationView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()
    }

	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any) {
		pokemonService.applyToAll(pokemon: pokemon, allPokemon: allPokemon)
		performSegue(withIdentifier: isFromSettings ? "unwindFromSettings" : "unwindFromGameSettings", sender: self)
	}
}
