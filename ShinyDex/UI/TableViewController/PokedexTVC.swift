//
//  PokedexTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 11/03/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PokedexTVC: UITableViewController, PokemonCellDelegate
{
	let searchController = UISearchController(searchResultsController: nil)
	
	var filteredPokemon = [Pokemon]()
	var allPokemon = [Pokemon]()
	var hunts: [Hunt]!
	let textResolver = TextResolver()
	var encounterIndex = 0
	var generation = 0
	var changeCaughtBallPressed = false
	var isAddingToHunt = false
	var pokemon: Pokemon?
	var popupHandler = PopupHandler()
	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntService: HuntService!
	var huntStateService: HuntStateService!

	@IBOutlet var popupView: PopupView!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		tableView.separatorColor = colorService.getSecondaryColor()

		slicePokemonList()
		
		setUIColors()

		setUpScopeBar()
		
		setUpSearchController()
		
		setUpBackButton()
		
		setFonts()
		
		roundPopupViewCorners()
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setTitle()

		hunts = huntService.getAll()

		tableView.reloadData()
	}
	
	fileprivate func setUIColors()
	{
		popupView.backgroundColor = colorService!.getSecondaryColor()
		
		popupView.actionLabel.textColor = colorService!.getTertiaryColor()
		
		popupView.iconImageView.tintColor = colorService!.getTertiaryColor()
		
		navigationController?.navigationBar.backgroundColor = colorService!.getSecondaryColor()
		
		tableView.backgroundColor = colorService!.getSecondaryColor()
		
		searchController.searchBar.backgroundColor = colorService!.getSecondaryColor()
		searchController.searchBar.barTintColor = colorService!.getSecondaryColor()
	}
	
	fileprivate func setUpScopeBar()
	{
		searchController.searchBar.scopeButtonTitles = generation == 9 ? ["Caught"] : ["Shinydex", "Caught", "Not Caught"]
		searchController.searchBar.delegate = self
	}
	
	fileprivate func setUpSearchController()
	{
		searchController.searchResultsUpdater = self
		
		searchController.obscuresBackgroundDuringPresentation = false
		
		searchController.searchBar.placeholder = "Search"
		
		navigationItem.searchController = searchController
		
		definesPresentationContext = true
	}
	
	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = colorService!.getTertiaryColor()
	}
	
	fileprivate func setNavigationBarFont()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getXxLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setFonts()
	{
		let attributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getSmallFont()
		]
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
		let searchBarTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField
		searchBarTextField?.textColor = colorService.getTertiaryColor()
		searchBarTextField?.font = fontSettingsService.getSmallFont()
		let searchBarPlaceHolderLabel = searchBarTextField!.value(forKey: "placeholderLabel") as? UILabel
		searchBarPlaceHolderLabel?.font = fontSettingsService.getSmallFont()
		searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font: fontSettingsService.getXxSmallFont(), NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()], for: .normal)
		
		popupView.actionLabel.font = fontSettingsService.getSmallFont()
	}
	
	fileprivate func roundPopupViewCorners()
	{
		popupView.layer.cornerRadius = CornerRadius.Standard.rawValue
	}
	
	fileprivate func setTitle()
	{
		navigationItem.title = textResolver.getGenTitle(gen: generation)
	}
	
	fileprivate func slicePokemonList()
	{
		switch generation
		{
		case 0:
			allPokemon = Array(allPokemon[0..<151])
		case 1:
			allPokemon = Array(allPokemon[151..<251])
		case 2:
			allPokemon = Array(allPokemon[251..<386])
		case 3:
			allPokemon = Array(allPokemon[386..<493])
		case 4:
			allPokemon = Array(allPokemon[493..<649])
		case 5:
			allPokemon = Array(allPokemon[649..<721])
		case 6:
			allPokemon = Array(allPokemon[721..<807])
		case 7:
			allPokemon = Array(allPokemon[807..<892])
		default:
			allPokemon = allPokemon.filter({$0.caughtBall != "none"})
		}
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
	{
		searchController.searchBar.resignFirstResponder()
	}
	
	func changeCaughtButtonPressed(_ sender: UIButton)
	{
		changeCaughtBallPressed = true
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			pokemon = getSelectedPokemon(index: indexPath.row)
			
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
		
		performSegue(withIdentifier: "pokedexToModalSegue", sender: self)
	}
	
	func addToHuntPressed(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			pokemon = getSelectedPokemon(index: indexPath.row)
			if hunts.isEmpty
			{
				huntService.createNewHuntWithPokemon(hunts: &hunts, pokemon: pokemon!)
				popupView.actionLabel.text = "\(pokemon!.name) was added to New Hunt."
				popupHandler.showPopup(popupView: popupView)
				tableView.reloadData()
			}
			else if hunts.count == 1
			{
				huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: pokemon!)
				popupView.actionLabel.text = "\(pokemon!.name) was added to \(hunts[0].name)."
				popupHandler.showPopup(popupView: popupView)
				tableView.reloadData()
			}
			else
			{
				isAddingToHunt = true
				performSegue(withIdentifier: "pokedexToHuntPickerSegue", sender: self)
			}
		}
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
	
	func searchBarIsEmpty() -> Bool
	{
		return searchController.searchBar.text?.isEmpty ?? true
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
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return isFiltering() ? filteredPokemon.count : allPokemon.count
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 65.0;
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
		cell.cellDelegate = self
		let pokemon = getSelectedPokemon(index: indexPath.row)
		setCellImage(pokemonCell: cell, pokemon: pokemon)
		setPokemonCellProperties(pokemonCell: cell, pokemon: pokemon)
        return cell
    }
	
	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.sprite.image = UIImage(named: pokemon.name.lowercased())
	}
	
	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.pokemonName?.text = pokemon.name
		pokemonCell.pokemonNumber.text = "No. \(String(pokemon.number + 1))"
		pokemonCell.caughtButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		pokemonCell.pokemonName.font = fontSettingsService.getSmallFont()
		pokemonCell.pokemonNumber.font = fontSettingsService.getExtraSmallFont()
		pokemonCell.pokemonName.textColor = colorService!.getTertiaryColor()
		pokemonCell.pokemonNumber.textColor = colorService!.getTertiaryColor()
		pokemonCell.addToCurrentHuntButton.tintColor = colorService!.getTertiaryColor()
		setAddToHuntButtonState(pokemonCell: pokemonCell, isBeingHunted: pokemon.isBeingHunted)
	}
	
	fileprivate func setAddToHuntButtonState(pokemonCell: PokemonCell, isBeingHunted: Bool)
	{
		pokemonCell.addToCurrentHuntButton.isEnabled = !isBeingHunted
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		encounterIndex = indexPath.row
		performSegue(withIdentifier: "encountersSegue", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if changeCaughtBallPressed
		{
			changeCaughtBallPressed = false
			let destVC = segue.destination as? PokeballModalVC
			destVC?.fontSettingsService = fontSettingsService
			setPokeballModalProperties(pokeballModalVC: destVC!)
		}
		else if isAddingToHunt
		{
			isAddingToHunt = false
			let destVC = segue.destination as? HuntPickerModalVC
			destVC?.pokemonService = pokemonService
			destVC?.hunts = hunts
			destVC?.pokemon = pokemon
			destVC?.huntService = huntService
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
			setShinyTrackerProperties(shinyTrackerVC: destVC!)
		}
	}
	
	fileprivate func setPokeballModalProperties(pokeballModalVC: PokeballModalVC)
	{
		pokeballModalVC.pokemonService = pokemonService
		pokeballModalVC.pokemon = pokemon
	}
	
	fileprivate func setShinyTrackerProperties(shinyTrackerVC: ShinyTrackerVC)
	{
		shinyTrackerVC.pokemonService = pokemonService
		shinyTrackerVC.huntStateService = huntStateService
		shinyTrackerVC.huntService = huntService
		shinyTrackerVC.pokemon = allPokemon[getIndexFromFullList(index: encounterIndex)]
		shinyTrackerVC.hunts = hunts
	}
	
	@IBAction func cancel(_ unwindSegue: UIStoryboardSegue)
	{}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue)
	{
		if let sourceTVC = unwindSegue.source as? PokeballModalVC
		{
			pokemon?.caughtBall = sourceTVC.pokemon.caughtBall
			pokemonService.save(pokemon: pokemon!)
			tableView.reloadData()
		}
	}
	
	fileprivate func getIndexFromFullList(index: Int) -> Int
	{
		var indexOfPokemon: Int
		if isFiltering()
		{
			indexOfPokemon = filteredPokemon[index].number - resolveCounter(generation: generation)
			return indexOfPokemon
		}
		indexOfPokemon = allPokemon[index].number - resolveCounter(generation: generation)
		return indexOfPokemon
	}

	fileprivate func resolveCounter(generation: Int) -> Int
	{
		switch generation
		{
		case 1:
			return 151
		case 2:
			return 251
		case 3:
			return 386
		case 4:
			return 493
		case 5:
			return 649
		case 6:
			return 721
		case 7:
			return 807
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService!.getPrimaryColor()
	}

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue)
	{
		tableView.reloadData()
		let source = unwindSegue.source as! HuntPickerModalVC
		let name = source.pickedHuntName!
		popupView.actionLabel.text = "\(pokemon!.name) was added to \(name)."
		popupHandler.showPopup(popupView: popupView)
	}
}
