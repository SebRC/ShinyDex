//
//  SetEncountersModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 13/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class SetEncountersModalVC: UIViewController
{
	@IBOutlet weak var setEncountersView: SetEncountersView!
	
	var pokemon: Pokemon!
	var pokemonRepository: PokemonRepository!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		roundViewCorners()

		setSpriteImageView()
		
		setLabelTexts()
		
		setButtonActions()
    }
	
	fileprivate func roundViewCorners()
	{
		setEncountersView.layer.cornerRadius = 5
	}
	
	fileprivate func setSpriteImageView()
	{
		setEncountersView.spriteImageView.image = pokemon.shinyImage
	}
	
	fileprivate func setLabelTexts()
	{
		setEncountersView.nameLabel.text = " \(pokemon.name)"
		setEncountersView.numberLabel.text = " No. \(pokemon.number + 1)"
		setEncountersView.encountersLabel.text = " Current encounters: \(pokemon.encounters)"
	}
	
	fileprivate func setButtonActions()
	{
		setEncountersView.cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
		setEncountersView.confirmButton.addTarget(self, action: #selector(confirmPressed), for: .touchUpInside)
	}
	
	@objc fileprivate func cancelPressed()
	{
		dismiss(animated: true)
	}
	
	@objc fileprivate func confirmPressed()
	{
		pokemon.encounters = Int(setEncountersView.encountersTextField.text!) ?? pokemon.encounters
		setEncountersView.encountersTextField.resignFirstResponder()
		setEncountersView.encountersTextField.text = ""
		
		performSegue(withIdentifier: "encountersUnwind", sender: self)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
