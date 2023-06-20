import UIKit

@IBDesignable
class ButtonStrip: UIView {
	@IBOutlet weak var methodMapSeparator: UIView!
	@IBOutlet weak var updateEncountersButton: UIButton!
	@IBOutlet weak var methodButton: UIButton!
	@IBOutlet weak var encountersIncrementSeparator: UIView!
	@IBOutlet weak var pokeballButton: UIButton!
	@IBOutlet weak var mapBallSeparator: UIView!
	@IBOutlet weak var locationButton: UIButton!
	@IBOutlet weak var ballOddsSeparator: UIView!
	@IBOutlet weak var oddsLabel: UILabel!
	@IBOutlet weak var incrementButton: UIButton!
	@IBOutlet weak var incrementMethodSeparator: UIView!

	let nibName = "ButtonStrip"
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
        contentView?.backgroundColor = Color.Grey800
		
		encountersIncrementSeparator.backgroundColor = Color.Grey900
		incrementMethodSeparator.backgroundColor = Color.Grey900
		methodMapSeparator.backgroundColor = Color.Grey900
		mapBallSeparator.backgroundColor = Color.Grey900
		ballOddsSeparator.backgroundColor = Color.Grey900
		updateEncountersButton.tintColor = Color.Grey200
		incrementButton.tintColor = Color.Grey200
		methodButton.tintColor = Color.Grey200
		oddsLabel.textColor = Color.Grey200
	}
	
	fileprivate func roundCorners() {
		encountersIncrementSeparator.layer.cornerRadius = CornerRadius.standard
		incrementMethodSeparator.layer.cornerRadius = CornerRadius.standard
		methodMapSeparator.layer.cornerRadius = CornerRadius.standard
		mapBallSeparator.layer.cornerRadius = CornerRadius.standard
		ballOddsSeparator.layer.cornerRadius = CornerRadius.standard
		layer.cornerRadius = CornerRadius.standard
	}
}
