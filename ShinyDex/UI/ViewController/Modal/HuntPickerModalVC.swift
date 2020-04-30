//
//  HuntPickerModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 27/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class HuntPickerModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
	var hunts: [Hunt]!
	var pokemon: Pokemon!
	var pokemonService: PokemonService!
	var huntService: HuntService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!

	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .clear
		cancelButton.titleLabel?.font = fontSettingsService.getLargeFont()
		cancelButton.titleLabel?.textColor = colorService.getTertiaryColor()
		cancelButton.layer.cornerRadius = 10
		tableView.separatorColor = colorService.getSecondaryColor()
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return hunts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "huntPickerCell") as! HuntPickerCell
		cell.nameLabel.text = hunts[indexPath.row].name
		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.nameLabel.font = fontSettingsService.getMediumFont()
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let hunt = hunts[indexPath.row]
		hunt.pokemon.append(pokemon)
		hunt.indexes.append(pokemon.number)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntService.save(hunt: hunt)
		performSegue(withIdentifier: "unwindFromHuntPicker", sender: self)
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService.getPrimaryColor()
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}
