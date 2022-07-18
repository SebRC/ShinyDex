import Foundation
import UIKit

class MoveCell: UITableViewCell {
	var cellDelegate: MoveCellDelegate?
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var ppLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var typeImageView: UIImageView!
	@IBOutlet weak var decrementButton: UIButton!
	@IBOutlet weak var incrementButton: UIButton!
	@IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var separator: UIView!
    
	@IBAction func decrementPressed(_ sender: UIButton) {
		cellDelegate?.decrementPressed(sender)
	}

	@IBAction func incrementPressed(_ sender: UIButton) {
		cellDelegate?.incrementPressed(sender)
	}
}
