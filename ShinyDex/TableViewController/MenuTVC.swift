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
	let resolver = Resolver()
	let textResolver = TextResolver()
	var genIndex = 0
	var pokemonRepository: PokemonRepository!
	var settingsRepository: SettingsRepository?
	var currentHuntRepository: CurrentHuntRepository?
	@IBOutlet weak var settingsButton: UIBarButtonItem!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		hideBackButton()
		
		showNavigationBar()
		
		createSettingsRepository()
		
		setNavigationControllerColor()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
		
		createCurrentHuntRepository()
		
		if currentHuntRepository!.currentlyHunting.isEmpty
		{
			loadCurrentHunt()
		}
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setTableViewBackgroundColor()
		
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
		navigationController?.navigationBar.barTintColor = settingsRepository?.getSecondaryColor()
	}
	
	fileprivate func createSettingsRepository()
	{
		if settingsRepository == nil
		{
			settingsRepository = SettingsRepository.settingsRepositorySingleton
		}
	}
	
	fileprivate func createCurrentHuntRepository()
	{
		if currentHuntRepository == nil
		{
			currentHuntRepository = CurrentHuntRepository.currentHuntRepositorySingleton
		}
	}
	
	fileprivate func loadCurrentHunt()
	{
		currentHuntRepository!.loadCurrentHunt()
	}
	
	fileprivate func setNavigationBarFont()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: settingsRepository!.getTertiaryColor(),
			NSAttributedString.Key.font: settingsRepository!.getXxLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setSettingsIconColor()
	{
		settingsButton.tintColor = settingsRepository?.getTertiaryColor()
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		tableView.backgroundColor = settingsRepository!.getPrimaryColor()
	}

	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = settingsRepository?.getTertiaryColor()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 8
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 160.0;
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		genIndex = indexPath.row
		if genIndex == 7
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
		
		let showCurrentHuntImage = indexPath.row == 7 && !(currentHuntRepository?.currentlyHunting.isEmpty)!
		
		cell.generationLabel.textColor = settingsRepository?.getTertiaryColor()
		
		if showCurrentHuntImage
		{
			cell.generationImage.image = currentHuntRepository?.currentlyHunting[0].shinyImage
		}
		else
		{
			cell.generationImage.image = resolveGenImage(gen: indexPath.row)
		}
		
		cell.generationLabel.text = textResolver.resolveGenTitle(gen: indexPath.row)
		cell.generationLabel.font = settingsRepository!.getXxLargeFont()
		
		return cell
	}
	
	fileprivate func resolveGenImage(gen : Int) -> UIImage
	{
		if gen == 0
		{
			return UIImage(named: "gen1")!
		}
		if gen == 1
		{
			return UIImage(named: "gen2")!
		}
		if gen == 2
		{
			return UIImage(named: "gen3")!
		}
		if gen == 3
		{
			return UIImage(named: "gen4")!
		}
		if gen == 4
		{
			return UIImage(named: "gen5")!
		}
		if gen == 5
		{
			return UIImage(named: "gen6")!
		}
		if gen == 6
		{
			return UIImage(named: "gen7")!
		}
		if gen == 7
		{
			return UIImage(named: "shiny-charm")!
		}
		return UIImage(named: "gen1")!
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if genIndex == 7
		{
			let destVC = segue.destination as? CurrentHuntTVC

			setCurrentHuntRepositories(currentHuntTVC: destVC!)
		}
		else if genIndex == 8
		{
			let destVC = segue.destination as? SettingsVC
			
			destVC?.settingsRepository = settingsRepository
		}
		else
		{
			let destVC = segue.destination as? PokedexTVC
			
			setPokedexRepositories(pokedexTVC: destVC!)
		}
	}
	
	fileprivate func setCurrentHuntRepositories(currentHuntTVC: CurrentHuntTVC)
	{
		currentHuntTVC.pokemonRepository = pokemonRepository
		currentHuntTVC.settingsRepository = settingsRepository
		currentHuntTVC.currentHuntRepository = currentHuntRepository
	}
	
	fileprivate func setPokedexRepositories(pokedexTVC: PokedexTVC)
	{
		pokedexTVC.generation = genIndex
		pokedexTVC.pokemonRepository = pokemonRepository
		pokedexTVC.settingsRepository = settingsRepository
		pokedexTVC.currentHuntRepository = currentHuntRepository
	}
	
	@IBAction func settingsPressed(_ sender: Any)
	{
		genIndex = 8
		performSegue(withIdentifier: "settingsSegue", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = settingsRepository!.getPrimaryColor()
	}
}
