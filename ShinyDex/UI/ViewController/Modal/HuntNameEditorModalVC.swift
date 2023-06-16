import UIKit

class HuntNameEditorModalVC: UIViewController {
	var huntService = HuntService()
	var colorService = ColorService()
	var hunt: Hunt!

	@IBOutlet weak var editorView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleLabel.text = "Change name of \(hunt.name)"
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.text = "Enter a new name"
		descriptionLabel.textColor = colorService.getTertiaryColor()
		textField.text = hunt.name
		textField.textColor = colorService.getTertiaryColor()
		textField.backgroundColor = colorService.getPrimaryColor()
		editorView.layer.cornerRadius = CornerRadius.standard
		editorView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()
        view.addBlur()
    }
	
	@IBAction func confirmpressed(_ sender: Any) {
		hunt.name = textField.text ?? "New Hunt"
		huntService.save(hunt: hunt)
		performSegue(withIdentifier: "unwindFromNameEditor", sender: self)
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}
