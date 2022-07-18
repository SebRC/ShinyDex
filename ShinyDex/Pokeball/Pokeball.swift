import Foundation
import UIKit

class Pokeball {
	var image: UIImage
	var name: String
	
	init(ballName: String) {
		image = UIImage(named: ballName)!
		name = ballName.capitalizingFirstLetter()
	}
}
