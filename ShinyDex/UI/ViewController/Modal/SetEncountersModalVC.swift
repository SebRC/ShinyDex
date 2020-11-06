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
	var methodDecrement: Int!
	var textResolver = TextResolver()
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		setSpriteImageView()
		setLabelTexts()
		setButtonActions()
    }
	
	fileprivate func setSpriteImageView()
	{
		setEncountersView.spriteImageView.image = UIImage(named: pokemon.name.lowercased())
	}
	
	fileprivate func setLabelTexts()
	{
		setEncountersView.nameLabel.text = " \(pokemon.name)"
		setEncountersView.numberLabel.text = " No. \(pokemon.number + 1)"
		setEncountersView.encountersLabel.text = " \(textResolver.getEncountersLabelText(pokemon: pokemon, encounters: pokemon.encounters, methodDecrement: methodDecrement))"
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
		
		performSegue(withIdentifier: "unwindFromEditEncounters", sender: self)
	}
}
