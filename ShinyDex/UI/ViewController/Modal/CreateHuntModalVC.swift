//
//  CreateHuntModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 26/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CreateHuntModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate, UISearchBarDelegate
{
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntService: HuntService!
	var pokemonService: PokemonService!
	var popupHandler = PopupHandler()
	var filteredPokemon = [Pokemon]()
	var allPokemon: [Pokemon]!
	var newHunt = Hunt(name: "New Hunt", pokemon: [Pokemon]())
	var hunts: [Hunt]!

	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var popupView: PopupView!
	@IBOutlet weak var searchBar: UISearchBar!

	override func viewDidLoad()
	{
        super.viewDidLoad()
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		textField.delegate = self
		confirmButton.isEnabled = false
		confirmButton.layer.cornerRadius = 10
		confirmButton.titleLabel?.font = fontSettingsService.getMediumFont()
		confirmButton.titleLabel?.textColor = colorService.getTertiaryColor()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.layer.cornerRadius = 10
		cancelButton.titleLabel?.font = fontSettingsService.getMediumFont()
		cancelButton.titleLabel?.textColor = colorService.getTertiaryColor()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		textField.font = fontSettingsService.getMediumFont()
		textField.textColor = colorService.getTertiaryColor()
		textField.backgroundColor = colorService.getPrimaryColor()
		tableView.separatorColor = colorService.getSecondaryColor()
		popupView.backgroundColor = colorService!.getSecondaryColor()
		popupView.actionLabel.textColor = colorService!.getTertiaryColor()
		popupView.iconImageView.tintColor = colorService!.getTertiaryColor()
		popupView.actionLabel.font = fontSettingsService.getSmallFont()
		popupView.layer.cornerRadius = 10
		setUpSearchController()
    }

	fileprivate func setUpSearchController()
	{
		//searchController.searchResultsUpdater = self
		//searchController.obscuresBackgroundDuringPresentation = false
		searchBar.placeholder = "Search"
		//searchController.definesPresentationContext = true
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
		searchBar.layer.cornerRadius = 10
		searchBar.barTintColor = colorService.getPrimaryColor()
		tableView.backgroundColor = .clear
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
	{
	   filterContentForSearchText(self.searchBar.text!)
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
	{
	   filterContentForSearchText(self.searchBar.text!)
	   self.searchBar.resignFirstResponder()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
	{
	   filterContentForSearchText(self.searchBar.text!)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return isFiltering() ? filteredPokemon.count : allPokemon.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "createHuntCell", for: indexPath) as! CreateHuntCell
		let pokemon = getSelectedPokemon(index: indexPath.row)
		if pokemon.isBeingHunted
		{
			cell.isUserInteractionEnabled = false
			cell.nameLabel.isEnabled = false
			cell.numberLabel.isEnabled = false
			cell.spriteImageView.alpha = 0.5
		}
		else
		{
			cell.isUserInteractionEnabled = true
			cell.nameLabel.isEnabled = true
			cell.numberLabel.isEnabled = true
			cell.spriteImageView.alpha = 1.0
		}
		cell.spriteImageView.image = pokemon.shinyImage
		cell.nameLabel.text = pokemon.name
		cell.numberLabel.text = "No. \(String(pokemon.number + 1))"
		cell.nameLabel.font = fontSettingsService.getSmallFont()
		cell.numberLabel.font = fontSettingsService.getExtraSmallFont()
		cell.nameLabel.textColor = colorService!.getTertiaryColor()
		cell.numberLabel.textColor = colorService!.getTertiaryColor()
        return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 65.0;
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let pokemon = getSelectedPokemon(index: indexPath.row)
		pokemon.isBeingHunted = true
		newHunt.pokemon.append(pokemon)
		newHunt.indexes.append(pokemon.number)
		confirmButton.isEnabled = true
		popupView.actionLabel.text = "\(pokemon.name) was added to \(newHunt.name)."
		popupHandler.showPopup(popupView: popupView)
		tableView.reloadData()
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService!.getPrimaryColor()
	}

	func filterContentForSearchText(_ searchText: String)
	{
		filteredPokemon = allPokemon.filter( {(pokemon : Pokemon) -> Bool in

			if searchBarIsEmpty()
			{
				return true
			}

			return pokemon.name.lowercased().contains(searchText.lowercased())
	})
		tableView.reloadData()
	}

	func isFiltering() -> Bool
	{
		return searchBar.searchTextField.isEditing && !searchBarIsEmpty()
	}

	func searchBarIsEmpty() -> Bool
	{
		return searchBar.text?.isEmpty ?? true
	}

	func getCurrentCellIndexPath(_ sender : UIButton) -> IndexPath?
	{
		let buttonPosition = sender.convert(CGPoint.zero, to : tableView)
		if let indexPath = tableView.indexPathForRow(at: buttonPosition)
		{
			return indexPath
		}
		return nil
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		newHunt.name = textField.text ?? "New Hunt"
		newHunt.pokemon = newHunt.pokemon.sorted(by: { $0.number < $1.number})
		for pokemon in newHunt.pokemon
		{
			pokemonService.save(pokemon: pokemon)
		}
		huntService.save(hunt: newHunt)
		hunts.append(newHunt)
		performSegue(withIdentifier: "confirmUnwindSegue", sender: self)
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		for pokemon in newHunt.pokemon
		{
			pokemon.isBeingHunted = false
		}
		dismiss(animated: true)
	}

	fileprivate func getSelectedPokemon(index: Int) -> Pokemon
	{
		if isFiltering()
		{
			return filteredPokemon[index]
		}
		else
		{
			return allPokemon[index]
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
        self.view.endEditing(true)
		newHunt.name = textField.text ?? "New Hunt"
        return false
    }
}
