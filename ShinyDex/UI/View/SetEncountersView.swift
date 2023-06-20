import UIKit
import Foundation

@IBDesignable
class SetEncountersView: UIView {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var encountersTextField: UITextField!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!

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
        contentView?.backgroundColor = Color.Grey900
        encountersTextField.backgroundColor = Color.Grey800
		encountersTextField.textColor = Color.Grey200
		
		titleLabel.backgroundColor = Color.Grey800
		titleLabel.textColor = Color.Grey200
		cancelButton.backgroundColor = Color.Danger500
		cancelButton.setTitleColor(Color.Danger100, for: .normal)
		confirmButton.backgroundColor = Color.Grey800
		confirmButton.setTitleColor(Color.Grey200, for: .normal)
		buttonSeparator.backgroundColor = Color.Grey900
	}
	
	fileprivate func roundCorners() {
		layer.cornerRadius = CornerRadius.standard
	}
}
