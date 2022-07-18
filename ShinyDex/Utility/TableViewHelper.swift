import Foundation
import UIKit

class TableViewHelper {
	func getPressedButtonIndexPath(_ sender : UIButton, _ tableView: UITableView) -> IndexPath? {
		let buttonPosition = sender.convert(CGPoint.zero, to : tableView)
		if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
			return indexPath
		}
		return nil
	}
}
