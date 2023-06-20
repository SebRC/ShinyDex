import Foundation
import UIKit

class IconTextView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageBackgroundView: UIView!
    
    let nibName = "IconTextView"
    var contentView: UIView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
        contentView?.layer.cornerRadius = CornerRadius.standard
        contentView?.backgroundColor = Color.Grey800
        label.textColor = Color.Grey200
        label.backgroundColor = .clear
        imageBackgroundView.makeCircle()
        imageBackgroundView.layer.borderWidth = 2
        imageBackgroundView.layer.borderColor = Color.Orange500.cgColor
        imageBackgroundView.backgroundColor = Color.Grey900
        imageView.tintColor = Color.Grey200
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
}
