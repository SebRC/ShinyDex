//
//  LoadingVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 28/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit
import JavaScriptCore

class LoadingVC: UIViewController
{
	@IBOutlet weak var loadingLabel: UILabel!
	var pokemonService = PokemonService()
	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()
	var isFirstTimeUser: Bool!
	var loadingGifData: Data?
	var pokeballGifData: Data?
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		resolveUserStatus()
		hideNavigationBar()

		if isFirstTimeUser
		{
			fontSettingsService.save(fontThemeName: FontThemeName.Retro.description)
		}

		view.backgroundColor = colorService.getSecondaryColor()
		loadingLabel.textColor = colorService.getTertiaryColor()
		loadingLabel.font = fontSettingsService.getMediumFont()
		
		if isFirstTimeUser
		{
			proceedAsNewUser()
		}
		else
		{
			//creatBase64ImageJson()
			//readJson()
			proceedAsExistingUser()
		}
    }
	
	fileprivate func resolveUserStatus()
	{
		let allPokemon = pokemonService.getAll()
		isFirstTimeUser = allPokemon.count == 0
	}
	
	fileprivate func hideNavigationBar()
	{
		navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func proceedAsNewUser()
	{
		pokemonService.populateDatabase()
		performSegue(withIdentifier: "load", sender: self)
	}
	
	fileprivate func proceedAsExistingUser()
	{
		performSegue(withIdentifier: "load", sender: self)
	}

	fileprivate func creatBase64ImageJson()
	{
		// Dictionary containing data as provided in your question.
//		case 0:
//			return Array(allPokemon[0..<151])
//		case 1:
//			return Array(allPokemon[151..<251])
//		case 2:
//			return Array(allPokemon[251..<386])
//		case 3:
//			return Array(allPokemon[386..<493])
//		case 4:
//			return Array(allPokemon[493..<649])
//		case 5:
//			return Array(allPokemon[649..<721])
//		case 6:
//			return Array(allPokemon[721..<807])
//		case 7:
//			return Array(allPokemon[807..<893])
		let allPokemon = pokemonService.getAll()
		var dictionary : [String : String] = Dictionary()
		let txtReader = TxtReader()

		var imageAsset = NSDataAsset(name: "Totodile")
		var encoded = ""
		for pokemon in allPokemon[0..<151]
		{
			print(pokemon.number)
			autoreleasepool
			{
				imageAsset = NSDataAsset(name: pokemon.name)
				encoded = imageAsset!.data.base64EncodedString()
				dictionary[pokemon.name] = encoded
			}
		}

		txtReader.write(dict: dictionary)

		// Working decoding
		//let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
	}

	fileprivate func readJson()
	{
		let txt = TxtReader()
		txt.parse(jsonData: txt.readJson()!)
	}
}
