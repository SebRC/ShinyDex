import Foundation
import UIKit

class IndicatorView: UIView {
	let nibName = "IndicatorView"
    var contentView: UIView?
	fileprivate var colorService = ColorService()
	fileprivate var fontSettingsService = FontSettingsService()

    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var pokemonImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
		titleLabel.textColor = colorService.getTertiaryColor()
		layer.cornerRadius = CornerRadius.standard
		contentView?.backgroundColor = colorService.getSecondaryColor()
		titleLabel.font = fontSettingsService.getSmallFont()
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
}
