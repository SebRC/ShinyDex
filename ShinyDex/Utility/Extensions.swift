import Foundation
import UIKit

extension PokedexTVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchBar = searchController.searchBar

		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
		filterContentForSearchText(searchController.searchBar.text!, scope: scope)
	}
}

extension PokedexTVC: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
	}
}

extension CreateHuntModalVC: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}

extension CreateHuntModalVC {
	func searchBar(_ searchBar: UISearchBar) {
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
	func initContentView(nibName: String, contentView: inout UIView?) {
        guard let view = loadViewFromNib(nibName: nibName) else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

	func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

	func makeCircle() {
		self.layer.cornerRadius = self.frame.size.width / 2
		self.clipsToBounds = true
	}
    
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

extension UIViewController {
    func setUpSearchController(searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
        let attributes =
        [
            NSAttributedString.Key.foregroundColor: Color.Grey200,
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.textColor = Color.Grey200
        let searchBarPlaceHolderLabel = searchBarTextField!.value(forKey: "placeholderLabel") as? UILabel
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = CornerRadius.standard
        searchBar.barTintColor = Color.Grey800
    }
}
