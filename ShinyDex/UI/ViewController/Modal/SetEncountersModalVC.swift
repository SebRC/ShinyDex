import UIKit

class SetEncountersModalVC: UIViewController {
	@IBOutlet weak var setEncountersView: SetEncountersView!
	
	var pokemon: Pokemon!
	var methodDecrement: Int!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setButtonActions()
        setEncountersView.encountersTextField.text = "\(pokemon.encounters)"
        view.addBlur()
    }
	
	fileprivate func setButtonActions() {
		setEncountersView.cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
		setEncountersView.confirmButton.addTarget(self, action: #selector(confirmPressed), for: .touchUpInside)
	}
	
	@objc fileprivate func cancelPressed() {
		dismiss(animated: true)
	}
	
	@objc fileprivate func confirmPressed() {
		let encounters = Int(setEncountersView.encountersTextField.text!) ?? pokemon.encounters
		pokemon.encounters = encounters > 500000 ? pokemon.encounters : encounters
		setEncountersView.encountersTextField.resignFirstResponder()
		performSegue(withIdentifier: "unwindFromEditEncounters", sender: self)
	}
}
