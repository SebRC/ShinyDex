//
//  CreateHuntModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 26/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CreateHuntModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PokemonCellDelegate,  UITextFieldDelegate
{
	let searchController = UISearchController(searchResultsController: nil)

	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var currentHuntService: CurrentHuntService!
	var filteredPokemon = [Pokemon]()
	var allPokemon: [Pokemon]!
	var newHunt = Hunt(name: "New Hunt", pokemon: [Pokemon]())
	var currentHunts: [Hunt]!

	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		textField.delegate = self
		setUpSearchController()
    }

	fileprivate func setUpSearchController()
	{
		searchController.searchResultsUpdater = self

		searchController.obscuresBackgroundDuringPresentation = false

		searchController.searchBar.placeholder = "Search Pokédex"

		searchController.definesPresentationContext = true

		searchController.view.backgroundColor = .red

		navigationItem.searchController = searchController

		definesPresentationContext = true
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredPokemon.count : allPokemon.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell

		cell.cellDelegate = self

		let pokemon = getSelectedPokemon(index: indexPath.row)

		setCellImage(pokemonCell: cell, pokemon: pokemon)

		setPokemonCellProperties(pokemonCell: cell, pokemon: pokemon)

        return cell
	}

	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.sprite.image = pokemon.shinyImage
	}

	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.pokemonName?.text = pokemon.name
		pokemonCell.pokemonNumber.text = "No. \(String(pokemon.number + 1))"
		pokemonCell.pokemonName.font = fontSettingsService.getSmallFont()
		pokemonCell.pokemonNumber.font = fontSettingsService.getExtraSmallFont()

		pokemonCell.pokemonName.textColor = colorService!.getTertiaryColor()
		pokemonCell.pokemonNumber.textColor = colorService!.getTertiaryColor()
		pokemonCell.addToCurrentHuntButton.tintColor = colorService!.getTertiaryColor()

		setAddToHuntButtonState(pokemonCell: pokemonCell, pokemon: pokemon)
	}

	fileprivate func setAddToHuntButtonState(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.addToCurrentHuntButton.isEnabled = !newHunt.pokemon.contains(pokemon)
	}

	func filterContentForSearchText(_ searchText: String, scope: String = "Regular")
	{
		filteredPokemon = allPokemon.filter( {(pokemon : Pokemon) -> Bool in

			let doesCategoryMatch = (scope == "Shinydex") || (scope == pokemon.caughtDescription)

			if searchBarIsEmpty()
			{
				return doesCategoryMatch
			}

			return doesCategoryMatch && pokemon.name.lowercased().contains(searchText.lowercased())
	})
		tableView.reloadData()
	}

	func isFiltering() -> Bool
	{
		let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
		return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
	}

	func searchBarIsEmpty() -> Bool
	{
		return searchController.searchBar.text?.isEmpty ?? true
	}

	func changeCaughtButtonPressed(_ sender: UIButton)
	{}

	func addToCurrenHuntPressed(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = getSelectedPokemon(index: indexPath.row)
			newHunt.pokemon.append(pokemon)
			newHunt.names.append(pokemon.name)
		}
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
		currentHuntService.save(hunt: newHunt)
		currentHunts.append(newHunt)
		performSegue(withIdentifier: "confirmUnwindSegue", sender: self)
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
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
        return false
    }
}
