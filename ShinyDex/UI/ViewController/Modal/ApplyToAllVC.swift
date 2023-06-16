import UIKit

class ApplyToAllVC: UIViewController {
	@IBOutlet weak var confirmationView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var descriptionLabel: UILabel!

	let pokemonService = PokemonService()
	var pokemon: Pokemon!
	var allPokemon = [Pokemon]()
	var isFromSettings = true

	override func viewDidLoad() {
        super.viewDidLoad()
		allPokemon = pokemonService.getAll()
        titleLabel.textColor = Color.Grey200
        titleLabel.backgroundColor = Color.Grey800
		descriptionLabel.textColor = Color.Grey200
		confirmationView.layer.cornerRadius = CornerRadius.standard
		confirmationView.backgroundColor = Color.Grey900
		confirmButton.backgroundColor = Color.Grey800
		confirmButton.setTitleColor(Color.Grey200, for: .normal)
        cancelButton.backgroundColor = Color.Danger500
		cancelButton.setTitleColor(Color.Danger100, for: .normal)
        horizontalSeparator.backgroundColor = Color.Grey900
		verticalSeparator.backgroundColor = Color.Grey900
    }

	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any) {
		pokemonService.applyToAll(pokemon: pokemon, allPokemon: allPokemon)
		performSegue(withIdentifier: isFromSettings ? "unwindFromSettings" : "unwindFromGameSettings", sender: self)
	}
}
