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

extension Int {
	fileprivate static let groupingFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()

	fileprivate static let abbreviations: [(divisor: Double, suffix: String)] = [(1_000_000_000, "B"), (1_000_000, "M")]

	var grouped: String {
		return Int.groupingFormatter.string(from: NSNumber(value: self)) ?? String(self)
	}

	func abbreviated(in locale: Locale = .current) -> String {
		guard let abbreviation = Int.abbreviations.first(where: { Double(abs(self)) >= $0.divisor }) else { return grouped }
		let formatter = NumberFormatter()
		formatter.locale = locale
		formatter.usesSignificantDigits = true
		formatter.maximumSignificantDigits = 3
		let shortened = Double(self) / abbreviation.divisor
		return (formatter.string(from: NSNumber(value: shortened)) ?? String(shortened)) + abbreviation.suffix
	}
}
