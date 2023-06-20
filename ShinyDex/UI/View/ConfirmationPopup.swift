import Foundation
import UIKit

@IBDesignable
class ConfirmationPopup: UIView {
	let nibName = "ConfirmationPopup"
    var contentView: UIView?
	
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
        cancelButton.backgroundColor = Color.Danger500
        titleLabel.backgroundColor = Color.Grey800
        titleLabel.textColor = Color.Grey200
		descriptionLabel.textColor = Color.Grey200
		contentView?.backgroundColor = Color.Grey900
		buttonSeparator.backgroundColor = Color.Grey900
		confirmButton.backgroundColor = Color.Grey800
		confirmButton.setTitleColor(Color.Grey200, for: .normal)
		cancelButton.setTitleColor(Color.Grey200, for: .normal)
	}
}
