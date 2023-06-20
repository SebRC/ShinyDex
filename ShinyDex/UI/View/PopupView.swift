import Foundation
import UIKit

@IBDesignable
class PopupView: UIView {
	let nibName = "PopupView"
    var contentView: UIView?

	@IBOutlet weak var actionLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		initContentView(nibName: nibName, contentView: &contentView)
		initUI()
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
		initUI()
    }

	fileprivate func initUI() {
        contentView?.backgroundColor = Color.Grey800
        actionLabel.textColor = Color.Success100
        iconImageView.tintColor = Color.Success300
		contentView?.layer.cornerRadius = CornerRadius.standard
        contentView?.addShadow()
	}
}
