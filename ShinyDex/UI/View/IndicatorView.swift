import Foundation
import UIKit

class IndicatorView: UIView {
	let nibName = "IndicatorView"
    var contentView: UIView?

    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var pokemonImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
        titleLabel.textColor = Color.Grey200
		layer.cornerRadius = CornerRadius.standard
        contentView?.backgroundColor = Color.Grey800
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
}
