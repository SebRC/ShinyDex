import Foundation
import UIKit

@IBDesignable
class ConfirmationPopup: UIView {
	let nibName = "ConfirmationPopup"
    var contentView: UIView?
	
	var colorService = ColorService()
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
		setColors()
		layer.cornerRadius = CornerRadius.standard
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
		initContentView(nibName: nibName, contentView: &contentView)
    }
	
	fileprivate func setColors() {
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		contentView?.backgroundColor = colorService.getSecondaryColor()
		buttonSeparator.backgroundColor = colorService.getSecondaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
	}
}
