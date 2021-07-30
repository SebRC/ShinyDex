//
//  LoadingVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 28/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class LoadingVC: UIViewController {
	@IBOutlet weak var loadingLabel: UILabel!
	var pokemonService = PokemonService()
	var moveService = MoveService()
	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()
	var isFirstTimeUser: Bool!
	var loadingGifData: Data?
	var pokeballGifData: Data?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		resolveUserStatus()
		hideNavigationBar()

		if (isFirstTimeUser) {
			fontSettingsService.save(fontThemeName: FontThemeName.Retro.description)
		}

		view.backgroundColor = colorService.getSecondaryColor()
		loadingLabel.textColor = colorService.getTertiaryColor()
		loadingLabel.font = fontSettingsService.getMediumFont()
		
		if (isFirstTimeUser) {
			proceedAsNewUser()
		}
		else {
			proceedAsExistingUser()
		}
    }
	
	fileprivate func resolveUserStatus() {
		let allPokemon = pokemonService.getAll()
		isFirstTimeUser = allPokemon.count == 0
	}
	
	fileprivate func hideNavigationBar() {
		navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func proceedAsNewUser()	{
		pokemonService.populateDatabase()
		moveService.populateDatabase()
		performSegue(withIdentifier: "load", sender: self)
	}
	
	fileprivate func proceedAsExistingUser() {
		performSegue(withIdentifier: "load", sender: self)
	}
}
