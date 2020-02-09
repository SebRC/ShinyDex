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
	var pokemonList = [Pokemon]()
	let resolver = Resolver()
	let textResolver = TextResolver()
	var encounterIndex = 0
	var generation = 0
	var changeCaughtBallPressed = false
	var pokemon: Pokemon?
	var popupHandler = PopupHandler()
	var pokemonRepository: PokemonRepository!
	var settingsRepo: SettingsRepository!
	var currentHuntRepo: CurrentHuntRepository!

	@IBOutlet var popupView: PopupView!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		extendedLayoutIncludesOpaqueBars = true
		
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

		slicePokemonList()

		tableView.reloadData()
	}
	
	fileprivate func setUIColors()
	{
		popupView.backgroundColor = settingsRepo.getSecondaryColor()
		
		navigationController?.navigationBar.backgroundColor = settingsRepo.getSecondaryColor()
		
		tableView.backgroundColor = settingsRepo.getSecondaryColor()
		
		searchController.searchBar.backgroundColor = settingsRepo.getSecondaryColor()
		searchController.searchBar.barTintColor = settingsRepo.getSecondaryColor()
	}
	
	fileprivate func setUpScopeBar()
	{
		searchController.searchBar.scopeButtonTitles = ["Shinydex", "Caught", "Not Caught"]
		searchController.searchBar.delegate = self
	}
	
	fileprivate func setUpSearchController()
	{
		searchController.searchResultsUpdater = self
		
		searchController.obscuresBackgroundDuringPresentation = false
		
		searchController.searchBar.placeholder = "Search Pokédex"
		
		navigationItem.searchController = searchController
		
		definesPresentationContext = true
	}
	
	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		navigationItem.backBarButtonItem = backButton
	}
	
	fileprivate func setFonts()
	{
		searchController.searchBar.change(textFont: settingsRepo.getSmallFont(), textColor: UIColor.white)
		searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font: settingsRepo.getXxSmallFont()], for: .normal)
		
		popupView.actionLabel.font = settingsRepo.getSmallFont()
	}
	
	fileprivate func roundPopupViewCorners()
	{
		popupView.layer.cornerRadius = 5
	}
	
	fileprivate func setTitle()
	{
		navigationItem.title = textResolver.resolveGenTitle(gen: generation)
	}
	
	fileprivate func slicePokemonList()
	{
		if generation == 0
		{
			pokemonList = Array(pokemonRepository!.pokemonList[0..<151])
		}
		else if generation == 1
		{
			pokemonList = Array(pokemonRepository!.pokemonList[151..<251])
		}
		else if generation == 2
		{
			pokemonList = Array(pokemonRepository!.pokemonList[251..<386])
		}
		else if generation == 3
		{
			pokemonList = Array(pokemonRepository!.pokemonList[386..<493])
		}
		else if generation == 4
		{
			pokemonList = Array(pokemonRepository!.pokemonList[493..<649])
		}
		else if generation == 5
		{
			pokemonList = Array(pokemonRepository!.pokemonList[649..<721])
		}
		else if generation == 6
		{
			pokemonList = Array(pokemonRepository!.pokemonList[721..<807])
		}
	}
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
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
	
	func addToCurrenHuntPressed(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			pokemon = getSelectedPokemon(index: indexPath.row)
			
			currentHuntRepo.addToCurrentHunt(pokemon: pokemon!)
		
			tableView.reloadRows(at: [indexPath], with: .automatic)
			
			popupView.actionLabel.text = "\(pokemon!.name) was added to current hunt."
			
			popupHandler.centerPopupView(popupView: popupView)
			
			popupHandler.showPopup(popupView: popupView)
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
			return pokemonList[index]
		}
	}
	
	func searchBarIsEmpty() -> Bool
	{
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "Regular")
	{
		filteredPokemon = pokemonList.filter( {(pokemon : Pokemon) -> Bool in
			
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
		if isFiltering()
		{
			return filteredPokemon.count
		}
		
        return pokemonList.count
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 50.0;
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
		
		cell.cellDelegate = self
		
		let pokemon = setCellPokemon(index: indexPath.row)
		
		setCellImage(pokemonCell: cell, pokemon: pokemon)
		
		setPokemonCellProperties(pokemonCell: cell, pokemon: pokemon)
		
        return cell
    }
	
	fileprivate func setCellPokemon(index: Int) -> Pokemon
	{
		if isFiltering()
		{
			return filteredPokemon[index]
		}
		
		return pokemonList[index]
	}
	
	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.sprite.image = pokemon.shinyImage
	}
	
	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: Pokemon)
	{
		pokemonCell.pokemonName?.text = pokemon.name
		pokemonCell.pokemonNumber.text = "No. \(String(pokemon.number + 1))"
		pokemonCell.caughtButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		pokemonCell.pokemonName.font = settingsRepo.getSmallFont()
		pokemonCell.pokemonNumber.font = settingsRepo.getExtraSmallFont()
		
		setAddToHuntButtonState(pokemonCell: pokemonCell)
	}
	
	fileprivate func setAddToHuntButtonState(pokemonCell: PokemonCell)
	{
		let containedName = pokemonCell.pokemonName.text
		
		pokemonCell.addToCurrentHuntButton.isEnabled = !currentHuntRepo.currentHuntNames.contains(containedName!)
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
			
			setPokeballModalProperties(pokeballModalVC: destVC!)
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
				
			setShinyTrackerProperties(shinyTrackerVC: destVC!)
		}
	}
	
	fileprivate func setPokeballModalProperties(pokeballModalVC: PokeballModalVC)
	{
		pokeballModalVC.pokemonRepository = pokemonRepository
		pokeballModalVC.pokemon = pokemon
		pokeballModalVC.settingsRepo = settingsRepo
	}
	
	fileprivate func setShinyTrackerProperties(shinyTrackerVC: ShinyTrackerVC)
	{
		shinyTrackerVC.pokemonRepository = pokemonRepository
		shinyTrackerVC.settingsRepo = settingsRepo
		shinyTrackerVC.currentHuntRepo = currentHuntRepo
		shinyTrackerVC.pokemon = pokemonList[getIndexFromFullList(index: encounterIndex)]
	}
	
	@IBAction func cancel(_ unwindSegue: UIStoryboardSegue)
	{}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue)
	{
		if let sourceTVC = unwindSegue.source as? PokeballModalVC
		{
			pokemon?.changeCaughtBall(pokemonRepository: pokemonRepository, newCaughtBall: sourceTVC.pokemon.caughtBall)
			
			tableView.reloadData()
		}
	}
	
	fileprivate func getIndexFromFullList(index: Int) -> Int
	{
		var indexOfPokemon: Int
		
		if isFiltering()
		{
			indexOfPokemon = filteredPokemon[index].number - resolver.resolveCounter(generation: generation)
			
			return indexOfPokemon
		}
		
		indexOfPokemon = pokemonList[index].number - resolver.resolveCounter(generation: generation)
		
		return indexOfPokemon
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = settingsRepo.getMainColor()
	}

}




