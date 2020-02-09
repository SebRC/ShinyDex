//
//  CurrentHuntTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CurrentHuntTVC: UITableViewController, CurrentHuntCellDelegate {

	var pokemonRepository: PokemonRepository!
	var settingsRepo: SettingsRepository!
	var currentHuntRepo: CurrentHuntRepository!
	var resolver = Resolver()
	var encounters = 0
	var index = 0
	var popupHandler = PopupHandler()
	var isClearingCurrentHunt = false
	
	@IBOutlet weak var clearCurrentHuntButton: UIBarButtonItem!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setClearHuntButtonState()
		
		setUpBackButton()
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setTableViewBackgroundColor()
		
		setEncounters()
		
		tableView.reloadData()
	}
	
	fileprivate func setClearHuntButtonState()
	{
		clearCurrentHuntButton.isEnabled = !currentHuntRepo.currentHuntNames.isEmpty
	}
	
	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		navigationItem.backBarButtonItem = backButton
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		tableView.backgroundColor = settingsRepo.getMainColor()
	}
	
	fileprivate func setEncounters()
	{
		encounters = resolveCurrentEncounters()
		navigationItem.title = String(encounters)
	}
	
	fileprivate func resolveCurrentEncounters() -> Int
	{
		let pokemonList = currentHuntRepo.currentlyHunting
		
		var encounters = 0
		for pokemon in pokemonList
		{
			encounters += pokemon.encounters
		}
		
		return encounters
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return currentHuntRepo.currentlyHunting.count
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 100.0
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentHuntCell", for: indexPath) as! CurrentHuntCell
		
		cell.cellDelegate = self
		
		let pokemon = currentHuntRepo.currentlyHunting[indexPath.row]
		
		let minusButtonIsEnabled = pokemon.encounters <= 0
		
		cell.minusButton.isEnabled = !minusButtonIsEnabled
		
		setCellProperties(currentHuntCell: cell, pokemon: pokemon)

        return cell
    }
	
	fileprivate func setCellProperties(currentHuntCell: CurrentHuntCell, pokemon: Pokemon)
	{
		currentHuntCell.sprite.image = pokemon.shinyImage
		currentHuntCell.nameLabel.text = pokemon.name
		currentHuntCell.numberLabel.text = "No. \(String(pokemon.number + 1))"
		currentHuntCell.encountersLabel.text = String(pokemon.encounters)
		currentHuntCell.nameLabel.font = settingsRepo.getSmallFont()
		currentHuntCell.numberLabel.font = settingsRepo.getExtraSmallFont()
		currentHuntCell.encountersLabel.font = settingsRepo.getLargeFont()
	}

	func decrementEncounters(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = currentHuntRepo.currentlyHunting[indexPath.row]
			
			pokemon.encounters -= 1
			encounters -= 1
			navigationItem.title = String(encounters)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			pokemonRepository.savePokemon(pokemon: pokemon)
		}
	}
	
	func incrementEncounters(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = currentHuntRepo.currentlyHunting[indexPath.row]
			
			pokemon.encounters += 1
			encounters += 1
			navigationItem.title = String(encounters)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			pokemonRepository.savePokemon(pokemon: pokemon)
		}
	}
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
		{
			encounters -= currentHuntRepo.currentlyHunting[indexPath.row].encounters
			currentHuntRepo.currentlyHunting.remove(at: indexPath.row)
			
			if !currentHuntRepo.currentHuntNames.isEmpty
			{
				currentHuntRepo.currentHuntNames.remove(at: indexPath.row)
			}
			
            tableView.deleteRows(at: [indexPath], with: .fade)
			navigationItem.title = String(encounters)
			currentHuntRepo.saveCurrentHunt()
			
			setClearHuntButtonState()
        }
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		index = indexPath.row
		performSegue(withIdentifier: "encountersSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if isClearingCurrentHunt
		{
			let destVC = segue.destination as? ConfirmationModalVC
			
			destVC?.settingsRepo = settingsRepo
			destVC?.currentHuntRepo = currentHuntRepo

			isClearingCurrentHunt = false
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
			
			destVC?.pokemonRepository = pokemonRepository
			destVC?.settingsRepo = settingsRepo
			destVC?.currentHuntRepo = currentHuntRepo
			destVC?.pokemon = currentHuntRepo.currentlyHunting[index]
		}
	}
	
	@IBAction func clearCurrentHuntPressed(_ sender: Any)
	{
		isClearingCurrentHunt = true
		performSegue(withIdentifier: "shinyTrackerToConfirmationModal", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = settingsRepo.getMainColor()
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		setClearHuntButtonState()
		tableView.reloadData()
		setEncounters()
	}
}
