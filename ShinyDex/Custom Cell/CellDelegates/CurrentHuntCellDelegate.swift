import UIKit

public protocol CurrentHuntCellDelegate {
	func decrementEncounters(_ sender: UIButton)
	func incrementEncounters(_ sender: UIButton)
}
