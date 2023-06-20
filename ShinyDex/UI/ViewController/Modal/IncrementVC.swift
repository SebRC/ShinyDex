import UIKit

class IncrementVC: UIViewController {
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var incrementSegmentedControl: UISegmentedControl!
	@IBOutlet weak var incrementTextField: UITextField!

	var pokemonService = PokemonService()
	var pokemon: Pokemon!
	var selectedIncrement = 1

	override func viewDidLoad() {
        super.viewDidLoad()
		selectedIncrement = pokemon.increment

		titleLabel.textColor = Color.Grey200
		titleLabel.backgroundColor = Color.Grey800
		descriptionLabel.textColor = Color.Grey200
		modalView.layer.cornerRadius = CornerRadius.standard
		modalView.backgroundColor = Color.Grey900
		confirmButton.backgroundColor = Color.Grey800
		confirmButton.setTitleColor(Color.Grey200, for: .normal)
		cancelButton.backgroundColor = Color.Danger500
		cancelButton.setTitleColor(Color.Danger100, for: .normal)
		incrementTextField.textColor = Color.Grey200
		incrementTextField.placeholder = "Custom increment"
		incrementTextField.backgroundColor = Color.Grey800
		horizontalSeparator.backgroundColor = Color.Grey900
		verticalSeparator.backgroundColor = Color.Grey900

		incrementSegmentedControl.backgroundColor = Color.Grey800
		incrementSegmentedControl.tintColor = Color.Grey200
        incrementSegmentedControl.selectedSegmentTintColor = Color.Orange500

		incrementSegmentedControl.selectedSegmentIndex = pokemon.increment > 6
		? 6
		: pokemon.increment - 1
		incrementTextField.isEnabled = incrementSegmentedControl.selectedSegmentIndex == 6
		incrementTextField.text = incrementTextField.isEnabled ? "\(pokemon.increment)" : ""
        setDescriptionText(increment: incrementSegmentedControl.selectedSegmentIndex)
        view.addBlur()
    }

	@IBAction func incrementChanged(_ sender: Any) {
		incrementTextField.isEnabled = incrementSegmentedControl.selectedSegmentIndex == 6
		selectedIncrement = getIncrement()
        setDescriptionText(increment: incrementSegmentedControl.selectedSegmentIndex)
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any) {
		pokemon.increment = getIncrement()
		pokemonService.save(pokemon: pokemon)
		performSegue(withIdentifier: "unwindFromEditIncrement", sender: self)
	}

	fileprivate func getIncrement() -> Int {
		let index = incrementSegmentedControl.selectedSegmentIndex
		return index == 6 && !incrementTextField.isEmpty()
			? getTextFieldIncrement()
			: getEmptyTextFieldIncrement(index: index)
	}

	fileprivate func getEmptyTextFieldIncrement(index: Int) -> Int {
		return index == 6 && incrementTextField.isEmpty() ? 1 : index  + 1
	}

	fileprivate func getTextFieldIncrement() -> Int {
		var increment = Int(incrementTextField.text!)!
		if (increment == 0 || increment > 100) {
			increment = 1
		}
		return increment
	}

	fileprivate func setDescriptionText(increment: Int) {
		switch increment {
		case 0:
			descriptionLabel.text = "Used for single encounters, like when soft resetting for a single Pokémon, Pokéradar chaining or chain fishing."
		case 1:
			descriptionLabel.text = "Used for double hunting, like when soft resetting for static encounters on multiple systems."
		case 2:
			descriptionLabel.text = "Used for Pokéradar chaining, when space is limited and three patches of grass are the most frequent."
		case 3:
			descriptionLabel.text = "Used for Pokéradar chaining, when you have plenty of space and four patches of grass are the most frequent."
		case 4:
			descriptionLabel.text = "Used for generation 6(X & Y) Pokéradar chaining, where five patches of grass can shake at once, or when receiving 5 gift Pokémon per reset."
		case 5:
			descriptionLabel.text = "Used for horde encounters, where six Pokémon appear at once."
		default:
			descriptionLabel.text = "Set your own custom increment. The minimum is 1 and the maximum is 100."
		}
	}
}
