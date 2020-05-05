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
	var pickedHuntName: String?
	var pokemon: Pokemon!
	var pokemonService: PokemonService!
	var huntService: HuntService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!

	@IBOutlet weak var pokemonIndicatorView: PokeballIndicatorView!
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
		pokemonIndicatorView.contentView?.backgroundColor = colorService.getSecondaryColor()
		pokemonIndicatorView.layer.cornerRadius = 10
		pokemonIndicatorView.pokemonImageView.image = pokemon.shinyImage
		pokemonIndicatorView.titleLabel.text = "Select a hunt to add \(pokemon.name) to"
		pokemonIndicatorView.titleLabel.font = fontSettingsService.getXxSmallFont()
		pokemonIndicatorView.titleLabel.textColor = colorService.getTertiaryColor()
		tableView.separatorColor = colorService.getPrimaryColor()
		tableView.layer.cornerRadius = 10
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
		pickedHuntName = hunt.name
		performSegue(withIdentifier: "unwindFromHuntPicker", sender: self)
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = colorService.getSecondaryColor()
	}

	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}
