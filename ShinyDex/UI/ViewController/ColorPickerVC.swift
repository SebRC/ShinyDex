import UIKit
import FlexColorPicker

class ColorPickerVC: CustomColorPickerViewController {
	var currentColor: Int!
	var theme: Theme!
	var colorService = ColorService()

	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var colorPreviewHex: ColorPreviewWithHex!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		selectedColor = UIColor(netHex: currentColor)
		
		view.backgroundColor = .white
		
		saveButton.layer.cornerRadius = CornerRadius.standard
		
		cancelButton.layer.cornerRadius = CornerRadius.standard
		
		titleLabel.textColor = .black
		
		switch theme {
		case .Primary:
			titleLabel.text = "Primary Color"
		case .Secondary:
			titleLabel.text = "Secondary Color"
		default:
			titleLabel.text = "Tertiary Color"
		}
	}
	
	@IBAction func savePressed(_ sender: Any) {
		let color = Int(selectedColor.hexValue(), radix: 16)
		colorService.save(hex: color!, name: theme.rawValue)
		performSegue(withIdentifier: "unwindFromColorPicker", sender: self)
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}
