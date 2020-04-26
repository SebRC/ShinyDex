//
//  CurrentHuntTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class CurrentHuntTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, CurrentHuntCellDelegate {

	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var currentHuntService: CurrentHuntService!
	var huntStateService: HuntStateService!
	var encounters = 0
	var selectedIndex = 0
	var selectedSection = 0
	var popupHandler = PopupHandler()
	var isClearingCurrentHunt = false
	var isCreatingHunt = false
	var currentHunts: [Hunt]!
	var allPokemon: [Pokemon]!
	
	@IBOutlet weak var addHuntImageView: UIImageView!
	@IBOutlet weak var addHuntButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var clearCurrentHuntButton: UIBarButtonItem!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorColor = colorService.getSecondaryColor()
		addHuntButton.layer.cornerRadius = 5
		addHuntButton.titleLabel?.font = fontSettingsService.getLargeFont()

		setClearHuntButtonState()
		
		setUpBackButton()
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setColors()
		
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
	
	fileprivate func setColors()
	{
		tableView.backgroundColor = colorService.getSecondaryColor()
		addHuntButton.backgroundColor = colorService.getPrimaryColor()
		addHuntImageView.tintColor = colorService.getTertiaryColor()
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

	func numberOfSections(in tableView: UITableView) -> Int
	{
		return currentHunts.count
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return currentHunts[section].pokemon.count
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 100.0
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
			let pokemon = currentHunts[indexPath.section].pokemon[indexPath.row]
			
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
			let pokemon = currentHunts[indexPath.section].pokemon[indexPath.row]
			pokemon.encounters += 1
			encounters += 1
			navigationItem.title = String(encounters)
			tableView.reloadRows(at: [indexPath], with: .automatic)
			pokemonService.save(pokemon: pokemon)
		}
	}

	fileprivate func getCurrentCellIndexPath(_ sender : UIButton) -> IndexPath?
	{
		let buttonPosition = sender.convert(CGPoint.zero, to : tableView)
		if let indexPath = tableView.indexPathForRow(at: buttonPosition)
		{
			return indexPath
		}

		return nil
	}
	
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
		{
			let currentHunt = currentHunts[indexPath.section]
			let pokemonName = currentHunt.pokemon[indexPath.row].name
			encounters -= currentHunt.pokemon[indexPath.row].encounters
			currentHunt.pokemon.remove(at: indexPath.row)
			currentHunt.names.removeAll{$0 == pokemonName}
            tableView.deleteRows(at: [indexPath], with: .fade)
			navigationItem.title = String(encounters)
			if currentHunt.pokemon.isEmpty
			{
				currentHunts.remove(at: indexPath.section)
				currentHuntService.delete(hunt: currentHunt)
			}
			else
			{
				currentHuntService.save(hunt: currentHunts[indexPath.section])
			}
			setClearHuntButtonState()
        }
		tableView.reloadData()
    }

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return currentHunts[section].name
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		selectedIndex = indexPath.row
		selectedSection = indexPath.section
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
		else if isCreatingHunt
		{
			isCreatingHunt = false
			let destVC = segue.destination as? CreateHuntModalVC
			destVC?.colorService = colorService
			destVC?.fontSettingsService = fontSettingsService
			destVC?.currentHuntService = currentHuntService
			destVC?.currentHunts = currentHunts
			destVC?.allPokemon = allPokemon
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemonService = pokemonService
			destVC?.huntStateService = huntStateService
			destVC?.currentHuntService = currentHuntService
			destVC?.pokemon = currentHunts[selectedSection].pokemon[selectedIndex]
			destVC?.fontSettingsService = fontSettingsService
			destVC?.colorService = colorService
		}
	}
	
	@IBAction func clearCurrentHuntPressed(_ sender: Any)
	{
		isClearingCurrentHunt = true
		performSegue(withIdentifier: "shinyTrackerToConfirmationModal", sender: self)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService!.getPrimaryColor()
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		clearCurrentHuntButton.isEnabled = false
		currentHunts.removeAll()
		tableView.reloadData()
		setEncounters()
	}

	@IBAction func createHuntConfirm(_ unwindSegue: UIStoryboardSegue)
	{
		if let source = unwindSegue.source as? CreateHuntModalVC
		{
			currentHunts = source.currentHunts
			tableView.reloadData()
			setEncounters()
		}
	}

	@IBAction func addHuntButtonPressed(_ sender: Any)
	{
		isCreatingHunt = true
		performSegue(withIdentifier: "createHuntSegue", sender: self)
	}
}
