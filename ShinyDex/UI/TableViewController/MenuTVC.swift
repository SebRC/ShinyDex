//
//  MenuTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 10/05/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class MenuTVC: UITableViewController
{
	var genIndex = 0
	var allPokemon = [Pokemon]()
	var hunts = [Hunt]()
	let textResolver = TextResolver()
	var pokemonService: PokemonService!
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var huntService = HuntService()
	var huntStateService = HuntStateService()

	@IBOutlet weak var settingsButton: UIBarButtonItem!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		hideBackButton()

		tableView.separatorColor = colorService.getSecondaryColor()

		hunts = huntService.getAll()
		
		showNavigationBar()

		setNavigationControllerColor()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		allPokemon = pokemonService.getAll()

		hunts = huntService.getAll()
		
		setTableViewBackgroundColor()

		tableView.separatorColor = colorService.getSecondaryColor()
		
		tableView.reloadData()
		
		setUpBackButton()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
	}
	
	fileprivate func hideBackButton()
	{
		navigationItem.hidesBackButton = true
	}
	
	fileprivate func showNavigationBar()
	{
		navigationController?.isNavigationBarHidden = false
	}
	
	fileprivate func setNavigationControllerColor()
	{
		navigationController?.navigationBar.barTintColor = colorService.getSecondaryColor()
	}
	
	fileprivate func setNavigationBarFont()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getXxLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setSettingsIconColor()
	{
		settingsButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		tableView.backgroundColor = colorService.getSecondaryColor()
	}

	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 10
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 160.0;
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		genIndex = indexPath.row
		if genIndex == 8
		{
			performSegue(withIdentifier: "currentHuntSegue", sender: self)
		}
		else
		{
			performSegue(withIdentifier: "pokedexSegue", sender: self)
		}
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
		
		let showCurrentHuntImage = indexPath.row == 8 && !hunts.isEmpty
		
		cell.generationLabel.textColor = colorService.getTertiaryColor()
		
		if showCurrentHuntImage
		{
			cell.generationImage.image = UIImage(named: hunts[0].pokemon[0].name.lowercased())
		}
		else
		{
			cell.generationImage.image = resolveGenImage(gen: indexPath.row)
		}
		
		cell.generationLabel.text = textResolver.getGenTitle(gen: indexPath.row)
		cell.generationLabel.font = fontSettingsService.getXxLargeFont()
		
		return cell
	}
	
	fileprivate func resolveGenImage(gen : Int) -> UIImage
	{
		switch gen
		{
		case 0:
			return UIImage(named: "gen1")!
		case 1:
			return UIImage(named: "gen2")!
		case 2:
			return UIImage(named: "gen3")!
		case 3:
			return UIImage(named: "gen4")!
		case 4:
			return UIImage(named: "gen5")!
		case 5:
			return UIImage(named: "gen6")!
		case 6:
			return UIImage(named: "gen7")!
		case 7:
			return UIImage(named: "gen8")!
		case 8:
			return UIImage(named: "shiny-charm")!
		case 9:
			return UIImage(named: "collection")!
		default:
			return UIImage(named: "gen1")!
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if genIndex == 8
		{
			let destVC = segue.destination as? HuntsTVC

			setCurrentHuntRepositories(huntsTVC: destVC!)
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
		else if genIndex == 10
		{
			let destVC = segue.destination as? SettingsVC
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
		else
		{
			let destVC = segue.destination as? PokedexTVC
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
			setPokedexRepositories(pokedexTVC: destVC!)
		}
	}
	
	fileprivate func setCurrentHuntRepositories(huntsTVC: HuntsTVC)
	{
		huntsTVC.pokemonService = pokemonService
		huntsTVC.huntStateService = huntStateService
		huntsTVC.huntService = huntService
		huntsTVC.hunts = hunts
		huntsTVC.allPokemon = allPokemon
	}
	
	fileprivate func setPokedexRepositories(pokedexTVC: PokedexTVC)
	{
		pokedexTVC.generation = genIndex
		pokedexTVC.pokemonService = pokemonService
		pokedexTVC.huntService = huntService
		pokedexTVC.huntStateService = huntStateService
		pokedexTVC.allPokemon = allPokemon
		pokedexTVC.hunts = hunts
	}
	
	@IBAction func settingsPressed(_ sender: Any)
	{
		genIndex = 10
		performSegue(withIdentifier: "settingsSegue", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService.getPrimaryColor()
	}
}
