//
//  GameSettingsModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsModalVC: UIViewController, UIAdaptivePresentationControllerDelegate, SegueActivated
{
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!
	@IBOutlet weak var scrollView: UIScrollView!
	var pokemon: Pokemon!
	var popupHandler = PopupHandler()
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.delegate = self

		presentationController?.delegate = self

		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: gameSettingsContainer.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true
		
		roundViewCorner()
    }
	
	fileprivate func roundViewCorner()
	{
		gameSettingsContainer.layer.cornerRadius = CornerRadius.Standard.rawValue
	}

	func presentationControllerWillDismiss(_ presentationController: UIPresentationController)
	{
		performSegue(withIdentifier: "infoUnwind", sender: self)
	}

	func segueActivated()
	{
		performSegue(withIdentifier: "gameSettingsToApplyToAllSegue", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "gameSettingsToApplyToAllSegue"
		{
			let destVC = segue.destination as! ApplyToAllVC
			destVC.pokemon = pokemon
			destVC.isFromSettings = false
		}
	}

	@IBAction func showGameSettingsConfirmation(_ unwindSegue: UIStoryboardSegue)
	{
		popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
	}
}
