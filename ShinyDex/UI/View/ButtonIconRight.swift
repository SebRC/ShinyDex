
import UIKit
import Foundation

@IBDesignable
class ButtonIconRight: UIView {
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var iconBackGroundView: UIView!
	@IBOutlet weak var backgroundView: UIView!

	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	let nibName = "ButtonIconRight"
    var contentView: UIView?
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)

		setColors()
		setFont()
		layer.cornerRadius = CornerRadius.standard
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }

	func setFont() {
		label.font = fontSettingsService.getXxSmallFont()
	}
	
	fileprivate func setColors() {
		contentView?.backgroundColor = colorService.getSecondaryColor()
		iconImageView.tintColor = .black
		iconBackGroundView.backgroundColor = .white
		label.backgroundColor = .white
		label.textColor = .black
	}
}
