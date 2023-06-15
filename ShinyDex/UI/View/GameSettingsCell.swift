import UIKit

class GameSettingsCell: UIView {
	var colorService = ColorService()

	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var separator: UIView!
    @IBOutlet weak var actionSwitch: UISwitch!
    
	let nibName = "GameSettingsCell"
    var contentView: UIView?

	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
		separator.layer.cornerRadius = CornerRadius.standard
		setUIColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }

	func setUIColors() {
		contentView?.backgroundColor = colorService.getPrimaryColor()
		separator.backgroundColor = colorService.getSecondaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		actionSwitch.onTintColor = colorService.getSecondaryColor()
		actionSwitch.thumbTintColor = colorService.getPrimaryColor()
	}
}
