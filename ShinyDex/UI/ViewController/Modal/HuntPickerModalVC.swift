//
//  HuntPickerModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 27/04/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class HuntPickerModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var hunts = [Hunt]()
	var pickedHuntName: String?
	var pokemon: Pokemon!
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	@IBOutlet weak var indicatorView: IndicatorView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
        super.viewDidLoad()
		hunts = huntService.getAll()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .clear
		cancelButton.titleLabel?.font = fontSettingsService.getLargeFont()
		cancelButton.titleLabel?.textColor = colorService.getTertiaryColor()
		cancelButton.layer.cornerRadius = CornerRadius.standard
		indicatorView.pokemonImageView.image = UIImage(named: pokemon.name.lowercased())
		indicatorView.titleLabel.text = "Select a hunt to add \(pokemon.name) to"
		tableView.separatorColor = colorService.getPrimaryColor()
		tableView.layer.cornerRadius = CornerRadius.standard
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int	{
		return hunts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "huntPickerCell") as! HuntPickerCell
		cell.nameLabel.text = hunts[indexPath.row].name
		cell.nameLabel.textColor = colorService.getTertiaryColor()
		cell.nameLabel.font = fontSettingsService.getMediumFont()
		cell.iconImageView.image = UIImage(named: hunts[indexPath.row].pokemon[0].name.lowercased())
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let hunt = hunts[indexPath.row]
		hunt.pokemon.append(pokemon)
		hunt.indexes.append(pokemon.number)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntService.save(hunt: hunt)
		pickedHuntName = hunt.name
		performSegue(withIdentifier: "unwindFromHuntPicker", sender: self)
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = colorService.getSecondaryColor()
	}

	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}
