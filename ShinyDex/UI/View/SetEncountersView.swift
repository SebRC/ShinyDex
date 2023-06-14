import UIKit
import Foundation

@IBDesignable
class SetEncountersView: UIView {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var encountersTextField: UITextField!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var spriteImageView: UIImageView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	@IBOutlet weak var spriteBackgroundView: UIView!

	var colorService = ColorService()
	
	let nibName = "SetEncountersView"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)

		setColors()
		roundCorners()
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
	
	fileprivate func setColors() {
		contentView?.backgroundColor = colorService.getSecondaryColor()
		spriteBackgroundView.backgroundColor = colorService.getPrimaryColor()
		encountersTextField.backgroundColor = colorService.getPrimaryColor()
		encountersTextField.textColor = colorService.getTertiaryColor()
		encountersTextField.attributedPlaceholder = NSAttributedString(string: "Set Encounters",
																	   attributes: [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor() as Any])
		
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		nameLabel.backgroundColor = colorService.getPrimaryColor()
		nameLabel.textColor = colorService.getTertiaryColor()
		numberLabel.backgroundColor = colorService.getPrimaryColor()
		numberLabel.textColor = colorService.getTertiaryColor()
		encountersLabel.backgroundColor = colorService.getPrimaryColor()
		encountersLabel.textColor = colorService.getTertiaryColor()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		buttonSeparator.backgroundColor = colorService.getSecondaryColor()
	}
	
	fileprivate func roundCorners() {
		nameLabel.layer.cornerRadius = CornerRadius.standard
		numberLabel.layer.cornerRadius = CornerRadius.standard
		encountersLabel.layer.cornerRadius = CornerRadius.standard
		spriteBackgroundView.layer.cornerRadius = CornerRadius.standard
		layer.cornerRadius = CornerRadius.standard
	}
}
