//
//  MovePickerModalTVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 30/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import UIKit

class MovePickerModalTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var moveService = MoveService()
	var allMoves = [Move]()
	var filteredMoves = [Move]()
	var selectedActiveMoveIndex: Int!
	var activeMoves: [ActiveMove]!

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		searchBar.delegate = self
		allMoves = moveService.getMoves()
		view.backgroundColor = colorService.getSecondaryColor()
		tableView.separatorColor = colorService.getSecondaryColor()
		tableView.backgroundColor = .clear
		setUpSearchController()
    }

	fileprivate func setUpSearchController() {
		searchBar.placeholder = "Search"
		let attributes =
		[
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getMediumFont()
		]
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
		let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchBarTextField?.textColor = colorService.getTertiaryColor()
		searchBarTextField?.font = fontSettingsService.getSmallFont()
		let searchBarPlaceHolderLabel = searchBarTextField!.value(forKey: "placeholderLabel") as? UILabel
		searchBarPlaceHolderLabel?.font = fontSettingsService.getSmallFont()
		searchBar.clipsToBounds = true
		searchBar.layer.cornerRadius = CornerRadius.Standard.rawValue
		searchBar.barTintColor = colorService.getPrimaryColor()
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
	   filterContentForSearchText(self.searchBar.text!)
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
	   filterContentForSearchText(self.searchBar.text!)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	   filterContentForSearchText(self.searchBar.text!)
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchBar.searchTextField.resignFirstResponder()
	}

	func filterContentForSearchText(_ searchText: String) {
		filteredMoves = allMoves.filter( {(move : Move) -> Bool in
			if (searchBarIsEmpty()) {
				return true
			}
			return move.identifier.lowercased().contains(searchText.lowercased())
		})
		tableView.reloadData()
	}

	func isFiltering() -> Bool {
		return !searchBarIsEmpty()
	}

	func searchBarIsEmpty() -> Bool {
		return searchBar.text?.isEmpty ?? true
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredMoves.count : allMoves.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "movePickerCell", for: indexPath) as! MovePickerCell
		cell.nameLabel.font = fontSettingsService.getSmallFont()
		cell.ppLabel.font = fontSettingsService.getSmallFont()
		cell.typeLabel.font = fontSettingsService.getSmallFont()

		cell.backgroundColor = colorService.getPrimaryColor()
		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.ppLabel.textColor = colorService.getTertiaryColor()
		cell.typeLabel.textColor = colorService.getTertiaryColor()

		cell.imageBackgroundView.makeCircle()

		let move = isFiltering() ? filteredMoves[indexPath.row] : allMoves[indexPath.row]
		let typeName = MoveTypes.Types[move.type_id]
		cell.imageBackgroundView.backgroundColor = MoveTypes.colors[typeName!]
		cell.nameLabel.text = cleanName(name: move.identifier)
		cell.ppLabel.text = "PP: \(move.pp ?? 0)"
		cell.typeLabel.text = MoveTypes.Types[move.type_id]
		cell.typeImageView.image = UIImage(named: MoveTypes.Types[move.type_id]!.lowercased())


		return cell
	}

	fileprivate func cleanName(name: String) -> String {
		return name.replacingOccurrences(of: "-", with: " ").capitalizingFirstLetter()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedMove = isFiltering() ? filteredMoves[indexPath.row] : allMoves[indexPath.row]
		let newActiveMove = ActiveMove(name: cleanName(name: selectedMove.identifier), maxPP: selectedMove.pp ?? 0, remainingPP: selectedMove.pp ?? 0, type: MoveTypes.Types[selectedMove.type_id]!)
		activeMoves[selectedActiveMoveIndex] = newActiveMove
		moveService.save(activeMoves: activeMoves)
		performSegue(withIdentifier: "unwindFromMovePicker", sender: self)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 155.0
	}
}
