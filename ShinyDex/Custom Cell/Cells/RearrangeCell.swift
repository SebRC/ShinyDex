import UIKit

class RearrangeCell: UITableViewCell {
	var cellDelegate: RearrangeCellDelegate?

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var moveUpButton: UIButton!
	@IBOutlet weak var moveDownButton: UIButton!
	@IBOutlet weak var iconImageView: UIImageView!
	
	@IBAction func moveUp(_ sender: UIButton) {
		cellDelegate?.moveUp(sender)
	}

	@IBAction func moveDown(_ sender: UIButton) {
		cellDelegate?.moveDown(sender)
	}
}
