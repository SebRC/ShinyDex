import UIKit
import Foundation

@IBDesignable
class SetEncountersView: UIView {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var encountersTextField: UITextField!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!

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
		encountersTextField.backgroundColor = colorService.getPrimaryColor()
		encountersTextField.textColor = colorService.getTertiaryColor()
		
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		buttonSeparator.backgroundColor = colorService.getSecondaryColor()
	}
	
	fileprivate func roundCorners() {
		layer.cornerRadius = CornerRadius.standard
	}
}
