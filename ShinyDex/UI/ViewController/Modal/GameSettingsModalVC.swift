//
//  GameSettingsModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsModalVC: UIViewController, UIAdaptivePresentationControllerDelegate
{
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!
	@IBOutlet weak var scrollView: UIScrollView!
	var pokemon: Pokemon!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()

		presentationController?.delegate = self

		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: gameSettingsContainer.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true
		
		setClearBackground()
		
		roundViewCorner()
    }
	
	fileprivate func setClearBackground()
	{
		view.backgroundColor = .clear
	}
	
	fileprivate func roundViewCorner()
	{
		gameSettingsContainer.layer.cornerRadius = CornerRadius.Standard.rawValue
	}

	func presentationControllerWillDismiss(_ presentationController: UIPresentationController)
	{
		performSegue(withIdentifier: "infoUnwind", sender: self)
	}
}
