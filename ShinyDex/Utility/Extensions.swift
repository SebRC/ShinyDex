//
//  Extensions.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 26/03/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

extension PokedexTVC: UISearchResultsUpdating
{
	func updateSearchResults(for searchController: UISearchController)
	{
		let searchBar = searchController.searchBar

		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
		filterContentForSearchText(searchController.searchBar.text!, scope: scope)
	}
}

extension PokedexTVC: UISearchBarDelegate
{
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
	{
		filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
	}
}

extension CreateHuntModalVC: UISearchResultsUpdating
{
	func updateSearchResults(for searchController: UISearchController)
	{
		filterContentForSearchText(searchController.searchBar.text!)
	}
}

extension CreateHuntModalVC
{
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
	{
		filterContentForSearchText(searchBar.text!)
	}
}

extension String
{
	func capitalizingFirstLetter() -> String
	{
		return prefix(1).uppercased() + self.lowercased().dropFirst()
	}

	mutating func capitalizeFirstLetter()
	{
		self = self.capitalizingFirstLetter()
	}
}

extension UIColor
{
	convenience init(red: Int, green: Int, blue: Int)
	{
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}

	convenience init(netHex:Int)
	{
		self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
	}

}

extension UITableViewController
{
	func getCurrentCellIndexPath(_ sender : UIButton) -> IndexPath?
	{
		let buttonPosition = sender.convert(CGPoint.zero, to : tableView)
		if let indexPath = tableView.indexPathForRow(at: buttonPosition)
		{
			return indexPath
		}

		return nil
	}
}

extension UIButton
{
  func underline()
{
    let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
	attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
    self.setAttributedTitle(attributedString, for: .normal)
  }
}

extension Double
{
	static func getPercentage(encounters: Int, odds: Int) -> Double
	{
		return Double(encounters) / Double(odds) * 100
	}
}
