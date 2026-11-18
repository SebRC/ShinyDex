import Foundation
import UIKit

class IndicatorView: UIView {
	let nibName = "IndicatorView"
    var contentView: UIView?

    @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var pokemonImageView: UIImageView!

	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

	fileprivate func setUp() {
		initContentView(nibName: nibName, contentView: &contentView)
		titleLabel.textColor = Color.Grey200
		layer.cornerRadius = CornerRadius.standard
		clipsToBounds = true
		contentView?.backgroundColor = Color.Grey800
	}
}
