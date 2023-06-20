import UIKit

class HuntNameEditorModalVC: UIViewController {
	var huntService = HuntService()
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
        titleLabel.textColor = Color.Grey200
		titleLabel.backgroundColor = Color.Grey800
		descriptionLabel.text = "Enter a new name"
		descriptionLabel.textColor = Color.Grey200
		textField.text = hunt.name
		textField.textColor = Color.Grey200
		textField.backgroundColor = Color.Grey800
		editorView.layer.cornerRadius = CornerRadius.standard
		editorView.backgroundColor = Color.Grey900
		confirmButton.backgroundColor = Color.Grey800
		confirmButton.setTitleColor(Color.Grey200, for: .normal)
        cancelButton.backgroundColor = Color.Danger500
        cancelButton.setTitleColor(Color.Danger100, for: .normal)
		horizontalSeparator.backgroundColor = Color.Grey900
		verticalSeparator.backgroundColor = Color.Grey900
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
