import Foundation
import UIKit

extension PokedexTVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text ?? "")
	}
}

extension PokedexTVC: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		filterContentForSearchText(searchBar.text!)
	}
}

extension String {
	func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + self.lowercased().dropFirst()
	}

	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
}

extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}

	convenience init(netHex:Int) {
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}

}

extension UIView {
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
}

extension UITextField {
	func isEmpty() -> Bool {
		return self.text == ""
	}
}

extension Double {
	static func getProbability(encounters: Int, odds: Int) -> Double {
		let cumulativeProbability = pow(Double(odds - 1)/Double(odds), Double(encounters))
		let decimalProbability = 1 - cumulativeProbability

		return Double(truncating: decimalProbability * 100 as NSNumber)
	}
}

extension Int {
	fileprivate static let groupingFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()

	/// The number with locale-aware thousands separators, e.g. 12,345.
	var grouped: String {
		return Int.groupingFormatter.string(from: NSNumber(value: self)) ?? String(self)
	}
}

extension Array {
	/// The element at `index`, or nil when it's out of range.
	subscript(safe index: Int) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
