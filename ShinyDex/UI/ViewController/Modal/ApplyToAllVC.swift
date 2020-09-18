//
//  ApplyToAllVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 18/09/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class ApplyToAllVC: UIViewController
{
	@IBOutlet weak var confirmationView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var descriptionLabel: UILabel!

	let fontSettingsService = FontSettingsService()
	let colorService = ColorService()
	let pokemonService = PokemonService()
	var pokemon: Pokemon!

	override func viewDidLoad()
	{
        super.viewDidLoad()
		titleLabel.font = fontSettingsService.getExtraSmallFont()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.font = fontSettingsService.getExtraSmallFont()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		confirmationView.layer.cornerRadius = CornerRadius.Standard.rawValue
		confirmationView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.titleLabel?.font = fontSettingsService.getSmallFont()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.titleLabel?.font = fontSettingsService.getSmallFont()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()

    }

	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		pokemonService.applyToAll(pokemon: pokemon)
		dismiss(animated: true)
	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
