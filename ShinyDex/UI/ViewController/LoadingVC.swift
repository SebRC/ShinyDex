//
//  LoadingVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 28/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class LoadingVC: UIViewController
{
	
	@IBOutlet weak var settingUpProfileLabel: UILabel!
	@IBOutlet weak var loadingImageView: UIImageView!
	@IBOutlet weak var pokeballImageView: UIImageView!
	var pokemonService = PokemonService()
	var isFirstTimeUser: Bool!
	var loadingGifData: Data?
	var pokeballGifData: Data?
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		resolveUserStatus()
		
		hideNavigationBar()
		
		displayGifs()
		
		setVisibilityOfSettingUpProfileLabel()
		
		if isFirstTimeUser
		{
			proceedAsNewUser()
		}
		else
		{
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
	
	fileprivate func displayGifs()
	{
		let loadingGifAsset = NSDataAsset(name: "loading")
		
		let loadingGifData = loadingGifAsset!.data
		
		let pokeballGifAsset = NSDataAsset(name: "original")
		
		let pokeballGifData = pokeballGifAsset!.data
		
		loadingImageView.image = UIImage.gifImageWithData(loadingGifData, 3000.0)
		pokeballImageView.image = UIImage.gifImageWithData(pokeballGifData, 900.0)
	}
	
	fileprivate func setVisibilityOfSettingUpProfileLabel()
	{
		settingUpProfileLabel.isHidden = isFirstTimeUser
	}
	
	fileprivate func proceedAsNewUser()
	{
		pokemonService.populateDatabase()
		
		performSegue(withIdentifier: "loadSegue", sender: self)
	}
	
	fileprivate func proceedAsExistingUser()
	{
		performSegue(withIdentifier: "loadSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as? MenuTVC
		
		destVC?.pokemonService = pokemonService
	}
}
