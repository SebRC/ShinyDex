//
//  CurrentHuntTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CurrentHuntTVC: UITableViewController, CurrentHuntCellDelegate {

	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var currentHuntService: CurrentHuntService!
	var huntStateService: HuntStateService!
	var encounters = 0
	var index = 0
	var popupHandler = PopupHandler()
	var isClearingCurrentHunt = false
	var currentHunts: [Hunt]!
	
	@IBOutlet weak var clearCurrentHuntButton: UIBarButtonItem!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		tableView.separatorColor = colorService.getSecondaryColor()

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
		clearCurrentHuntButton.isEnabled = !currentHunts.isEmpty
	}
	
	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		navigationItem.backBarButtonItem = backButton
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		tableView.backgroundColor = colorService!.getSecondaryColor()
	}
	
	fileprivate func setEncounters()
	{
		encounters = resolveCurrentEncounters()
		navigationItem.title = String(encounters)
	}
	
	fileprivate func resolveCurrentEncounters() -> Int
	{
		var encounters = 0
		for hunt in currentHunts
		{
			for pokemon in hunt.pokemon
			{
				encounters += pokemon.encounters
			}
		}
		return encounters
	}

	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return currentHunts.count
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return currentHunts[section].pokemon.count
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 100.0
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentHuntCell", for: indexPath) as! CurrentHuntCell
		
		cell.cellDelegate = self
		
		let pokemon = currentHunts[indexPath.section].pokemon[indexPath.row]
		
		let minusButtonIsEnabled = pokemon.encounters <= 0
		
		cell.minusButton.isEnabled = !minusButtonIsEnabled
		
		setCellProperties(currentHuntCell: cell, pokemon: pokemon)

        return cell
    }
	
	fileprivate func setCellProperties(currentHuntCell: CurrentHuntCell, pokemon: Pokemon)
	{
		currentHuntCell.sprite.image = pokemon.shinyImage
		
		currentHuntCell.nameLabel.text = pokemon.name
		currentHuntCell.nameLabel.textColor = colorService!.getTertiaryColor()
		currentHuntCell.nameLabel.font = fontSettingsService.getExtraSmallFont()
		
		currentHuntCell.numberLabel.text = "No. \(String(pokemon.number + 1))"
		currentHuntCell.numberLabel.textColor = colorService!.getTertiaryColor()
		currentHuntCell.numberLabel.font = fontSettingsService.getExtraSmallFont()
		
		currentHuntCell.encountersLabel.text = String(pokemon.encounters)
		currentHuntCell.encountersLabel.textColor = colorService!.getTertiaryColor()
		currentHuntCell.encountersLabel.font = fontSettingsService.getMediumFont()
		
		currentHuntCell.plusButton.tintColor = colorService!.getTertiaryColor()
		currentHuntCell.minusButton.tintColor = colorService!.getTertiaryColor()
	}

	func decrementEncounters(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = currentHunts[0].pokemon[indexPath.row]
			
			pokemon.encounters -= 1
			encounters -= 1
			navigationItem.title = String(encounters)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			pokemonService.save(pokemon: pokemon)
		}
	}
	
	func incrementEncounters(_ sender: UIButton)
	{
		if let indexPath = getCurrentCellIndexPath(sender)
		{
			let pokemon = currentHunts[0].pokemon[indexPath.row]
			pokemon.encounters += 1
			encounters += 1
			navigationItem.title = String(encounters)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			pokemonService.save(pokemon: pokemon)
		}
	}
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
		{
			encounters -= currentHunts[0].pokemon[indexPath.row].encounters
			currentHunts[0].pokemon.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
			navigationItem.title = String(encounters)
			currentHuntService.save(hunt: currentHunts[0])
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
			destVC?.currentHuntService = currentHuntService
			isClearingCurrentHunt = false
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemonService = pokemonService
			destVC?.huntStateService = huntStateService
			destVC?.currentHuntService = currentHuntService
			destVC?.pokemon = currentHunts[0].pokemon[index]
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
	}
	
	@IBAction func clearCurrentHuntPressed(_ sender: Any)
	{
		isClearingCurrentHunt = true
		performSegue(withIdentifier: "shinyTrackerToConfirmationModal", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService!.getPrimaryColor()
		cell.layer.cornerRadius = 30
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		clearCurrentHuntButton.isEnabled = false
		currentHunts.removeAll()
		tableView.reloadData()
		setEncounters()
	}
}
