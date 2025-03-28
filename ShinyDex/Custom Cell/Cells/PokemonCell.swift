import UIKit

class PokemonCell: UITableViewCell {
	var cellDelegate: PokemonCellDelegate?
	
	@IBOutlet weak var caughtButton: UIButton!
	@IBOutlet weak var pokemonName: UILabel!
	@IBOutlet weak var pokemonNumber: UILabel!
	@IBOutlet weak var sprite: UIImageView!
	@IBOutlet weak var addToCurrentHuntButton: UIButton!
	
	@IBAction func changeCaughtPressed(_ sender: UIButton) {
		cellDelegate?.changeCaughtButtonPressed(sender)
	}
	
	@IBAction func addToCurrentHuntPressed(_ sender: UIButton) {
		cellDelegate?.addToHuntPressed(sender)
	}
}
