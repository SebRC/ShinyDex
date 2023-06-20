import Foundation
import UIKit

class IconTextView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let nibName = "IconTextView"
    var contentView: UIView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
        contentView?.layer.cornerRadius = CornerRadius.standard
        contentView?.backgroundColor = Color.Grey800
        label.textColor = Color.Grey200
        label.backgroundColor = .clear
        imageView.makeCircle()
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = Color.Orange500.cgColor
        imageView.backgroundColor = Color.Grey900
        imageView.tintColor = Color.Grey200
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
}
