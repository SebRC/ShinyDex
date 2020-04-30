//
//  HuntsTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class HuntsTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CurrentHuntCellDelegate {

	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntService: HuntService!
	var huntStateService: HuntStateService!
	var encounters = 0
	var selectedIndex = 0
	var selectedSection = 0
	var popupHandler = PopupHandler()
	var isClearingCurrentHunt = false
	var isCreatingHunt = false
	var hunts: [Hunt]!
	var allPokemon: [Pokemon]!
	var collapsedSections = Set<Int>()
	
	@IBOutlet weak var createHuntImageView: UIImageView!
	@IBOutlet weak var createHuntButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var clearCurrentHuntButton: UIBarButtonItem!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		createHuntButton.layer.cornerRadius = 10
		createHuntButton.titleLabel?.font = fontSettingsService.getLargeFont()
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
		clearCurrentHuntButton.isEnabled = !hunts.isEmpty
	}
	
	fileprivate func setUpBackButton()
	{
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		navigationItem.backBarButtonItem = backButton
	}
	
	fileprivate func setColors()
	{
		tableView.backgroundColor = colorService.getSecondaryColor()
		tableView.separatorColor = colorService.getSecondaryColor()
		createHuntButton.backgroundColor = colorService.getPrimaryColor()
		createHuntImageView.tintColor = colorService.getTertiaryColor()
		createHuntButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
	}
	
	fileprivate func setEncounters()
	{
		encounters = resolveCurrentEncounters()
		navigationItem.title = String(encounters)
	}
	
	fileprivate func resolveCurrentEncounters() -> Int
	{
		var encounters = 0
		for hunt in hunts
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
		return hunts.count
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if collapsedSections.contains(section)
		{
			return 0
		}
		return hunts[section].pokemon.count
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 100.0
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentHuntCell", for: indexPath) as! CurrentHuntCell
		
		cell.cellDelegate = self
		
		let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
		
		let minusButtonIsEnabled = pokemon.encounters <= 0
		
		cell.minusButton.isEnabled = !minusButtonIsEnabled
		
		setCellProperties(currentHuntCell: cell, pokemon: pokemon)

        return cell
    }

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
	{
		let sectionView = UIView()
		sectionView.backgroundColor = .clear
		let collapseButton = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width / 2, height: 60))
		collapseButton.tag = section
		collapseButton.addTarget(self, action: #selector(collapseSection(sender:)), for: .touchUpInside)
		collapseButton.setTitle(hunts[section].name, for: .normal)
		collapseButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		collapseButton.backgroundColor = .clear
		collapseButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), for: .normal)
		collapseButton.imageView?.tintColor = colorService.getTertiaryColor()
		collapseButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 10, bottom: 0, right: 0)
		collapseButton.contentHorizontalAlignment = .left
		collapseButton.titleEdgeInsets = UIEdgeInsets(top: 25, left: 15, bottom: 0, right: 0)
		collapseButton.titleLabel?.font = fontSettingsService.getMediumFont()
		collapseButton.titleLabel?.alpha = 0.4
		let editButton = UIButton(frame: CGRect(x: collapseButton.frame.width, y: 0, width: tableView.frame.width / 2, height: 60))
		editButton.addTarget(self, action: #selector(editSectionHeader(sender:)), for: .touchUpInside)
		editButton.tag = section
		editButton.backgroundColor = .clear
		editButton.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle"), for: .normal)
		editButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 50)
		editButton.imageView?.tintColor = colorService.getTertiaryColor()
		editButton.contentHorizontalAlignment = .right
		sectionView.addSubview(collapseButton)
		sectionView.addSubview(editButton)
		return sectionView
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
	{
		let footerView = UIView()
		footerView.layer.cornerRadius = 5
		if collapsedSections.contains(section)
		{
			footerView.backgroundColor = colorService.getPrimaryColor()
		}
		else
		{
			footerView.backgroundColor = .clear
		}
		return footerView
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
	{
		return 5
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		return 60.0
	}

	@objc
	private func collapseSection(sender: UIButton)
	{
		let section = sender.tag

		func indexPathsForSection() -> [IndexPath] {
			var indexPaths = [IndexPath]()

			for row in 0..<hunts[section].pokemon.count
			{
				indexPaths.append(IndexPath(row: row, section: section))
			}

			return indexPaths
		}
		if collapsedSections.contains(section)
		{
			collapsedSections.remove(section)
			tableView.insertRows(at: indexPathsForSection(), with: .fade)
		}
		else
		{
			collapsedSections.insert(section)
			tableView.deleteRows(at: indexPathsForSection(), with: .fade)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
		{
			self.tableView.reloadData()
		}
	}

	@objc
	private func editSectionHeader(sender: UIButton)
	{
		let section = sender.tag
		let alert = UIAlertController(title: "Changing name of \(hunts[section].name)", message: "Enter a new name", preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.text = self.hunts[section].name
		}
		alert.view.backgroundColor = .clear
		alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
			let textField = alert?.textFields![0]
			self.hunts[section].name = textField!.text!
			self.huntService.save(hunt: self.hunts[section])
			self.tableView.reloadData()

		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			alert.dismiss(animated: true)
		}))
		self.present(alert, animated: true, completion: nil)
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
			let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
			
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
			let pokemon = hunts[indexPath.section].pokemon[indexPath.row]
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
			let currentHunt = hunts[indexPath.section]
			let pokemonNumber = currentHunt.pokemon[indexPath.row].number
			encounters -= currentHunt.pokemon[indexPath.row].encounters
			currentHunt.pokemon[indexPath.row].isBeingHunted = false
			allPokemon[pokemonNumber].isBeingHunted = false
			pokemonService.save(pokemon: currentHunt.pokemon[indexPath.row])
			currentHunt.pokemon.remove(at: indexPath.row)
			currentHunt.indexes.removeAll{$0 == pokemonNumber}
            tableView.deleteRows(at: [indexPath], with: .fade)
			navigationItem.title = String(encounters)
			if currentHunt.pokemon.isEmpty
			{
				hunts.remove(at: indexPath.section)
				huntService.delete(hunt: currentHunt)
			}
			else
			{
				huntService.save(hunt: hunts[indexPath.section])
			}
			setClearHuntButtonState()
        }
		tableView.reloadData()
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
			destVC?.huntService = huntService
			isClearingCurrentHunt = false
		}
		else if isCreatingHunt
		{
			isCreatingHunt = false
			let destVC = segue.destination as? CreateHuntModalVC
			destVC?.colorService = colorService
			destVC?.fontSettingsService = fontSettingsService
			destVC?.huntService = huntService
			destVC?.pokemonService = pokemonService
			destVC?.hunts = hunts
			destVC?.allPokemon = allPokemon
		}
		else
		{
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemonService = pokemonService
			destVC?.huntStateService = huntStateService
			destVC?.huntService = huntService
			destVC?.pokemon = hunts[selectedSection].pokemon[selectedIndex]
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
		for hunt in hunts
		{
			for pokemon in hunt.pokemon
			{
				allPokemon[pokemon.number].isBeingHunted = false
				pokemonService.save(pokemon: allPokemon[pokemon.number])
			}
		}
		hunts.removeAll()
		tableView.reloadData()
		setEncounters()
	}

	@IBAction func createHuntConfirm(_ unwindSegue: UIStoryboardSegue)
	{
		if let source = unwindSegue.source as? CreateHuntModalVC
		{
			hunts = source.hunts
			tableView.reloadData()
			setEncounters()
		}
		clearCurrentHuntButton.isEnabled = true
	}

	@IBAction func createHuntButtonPressed(_ sender: Any)
	{
		isCreatingHunt = true
		performSegue(withIdentifier: "createHuntSegue", sender: self)
	}
}
