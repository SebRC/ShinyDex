import UIKit

class GameSettingsCell: UIView {
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
        contentView?.backgroundColor = Color.Grey800
		separator.backgroundColor = Color.Grey900
		titleLabel.textColor = Color.Grey200
		descriptionLabel.textColor = Color.Grey200
        actionSwitch.onTintColor = Color.Orange500
        actionSwitch.thumbTintColor = Color.Grey900
	}
}
