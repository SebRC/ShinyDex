//
//  PokeballModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 08/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PokeballModalVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	@IBOutlet weak var pokeballIndicatorView: PokeballIndicatorView!
	@IBOutlet weak var pokeballTableView: UITableView!
	
	@IBOutlet weak var cancelButton: UIButton!
	var pokeballs = [Pokeball]()
	let txtReader = TxtReader()
	var pokemon: Pokemon!
	var pokemonRepository: PokemonRepository!
	var settingsRepository: SettingsRepository!
	var modalPosition: CGRect!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.pokeballTableView.delegate = self
		
		self.pokeballTableView.dataSource = self
		
		populatePokeballList()
		
		roundTableViewCorners()
		
		roundCancelButtonCorners()
		
		setCancelButtonFont()
		
		setTableViewBackgroundColor()
		
		pokeballIndicatorView.layer.cornerRadius = 5
		
		pokeballIndicatorView.backgroundColor = settingsRepository.getMainColor()
		
		pokeballIndicatorView.titleLabel.font = settingsRepository.getXxSmallFont()
		
		pokeballIndicatorView.titleLabel.text = "Changing \(pokemon.name) caught ball"
		
		pokeballIndicatorView.pokemonImageView.image = pokemon.shinyImage
    }
	
	fileprivate func populatePokeballList()
	{
		var pokeballList = txtReader.linesFromResourceForced(textFile: "pokeballs")
		
		pokeballList.removeLast()
		
		for pokeball in pokeballList
		{
			pokeballs.append(Pokeball(ballName: pokeball))
		}
	}
	
	fileprivate func roundTableViewCorners()
	{
		pokeballTableView.layer.cornerRadius = 10
	}
	
	fileprivate func roundCancelButtonCorners()
	{
		cancelButton.layer.cornerRadius = 5
	}
	
	fileprivate func setCancelButtonFont()
	{
		cancelButton.titleLabel?.font = settingsRepository.getMediumFont()
	}
	
	fileprivate func setTableViewBackgroundColor()
	{
		pokeballTableView.backgroundColor = settingsRepository.getMainColor()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 140.0
	}
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let pokeball = pokeballs[indexPath.row]
		
		pokemon.caughtBall = pokeball.name.lowercased()
		
		pokemonRepository.savePokemon(pokemon: pokemon)
		
		performSegue(withIdentifier: "unwindToShinyTrackerVC", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		cell.backgroundColor = settingsRepository.getMainColor()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return pokeballs.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "pokeballCell", for: indexPath) as! PokeballCell
		
		let pokeball = pokeballs[indexPath.row]

		setCellProperties(pokeballCell: cell, pokeball: pokeball)
		
        return cell
	}
	
	fileprivate func setCellProperties(pokeballCell: PokeballCell, pokeball: Pokeball)
	{
		setNameLabelFont(nameLabel: pokeballCell.nameLabel)

		pokeballCell.pokeballImageView.image = pokeball.image
		pokeballCell.nameLabel.text = pokeball.name
	}
	
	fileprivate func setNameLabelFont(nameLabel: UILabel)
	{
		nameLabel.font = settingsRepository.getLargeFont()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
