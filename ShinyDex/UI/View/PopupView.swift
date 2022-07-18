import Foundation
import UIKit

@IBDesignable
class PopupView: UIView {
	let nibName = "PopupView"
    var contentView: UIView?
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

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
		contentView?.backgroundColor = colorService.getSecondaryColor()
		actionLabel.textColor = colorService.getTertiaryColor()
		iconImageView.tintColor = colorService.getTertiaryColor()
		actionLabel.font = fontSettingsService.getSmallFont()
		contentView?.layer.cornerRadius = CornerRadius.standard
        contentView?.addShadow()
	}
}
