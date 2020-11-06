//
//  IncrementVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 07/08/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class IncrementVC: UIViewController
{
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var incrementSegmentedControl: UISegmentedControl!

	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()
	var pokemonService = PokemonService()
	var pokemon: Pokemon!
	var selectedIncrement = 1

	override func viewDidLoad()
	{
        super.viewDidLoad()
		selectedIncrement = pokemon.increment

		titleLabel.font = fontSettingsService.getExtraSmallFont()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.font = fontSettingsService.getExtraSmallFont()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		modalView.layer.cornerRadius = CornerRadius.Standard.rawValue
		modalView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.titleLabel?.font = fontSettingsService.getSmallFont()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.titleLabel?.font = fontSettingsService.getSmallFont()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()

		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]

		incrementSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		incrementSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		incrementSegmentedControl.backgroundColor = colorService.getPrimaryColor()
		incrementSegmentedControl.tintColor = colorService.getSecondaryColor()

		incrementSegmentedControl.selectedSegmentIndex = pokemon.increment - 1
		setDescriptionText(increment: pokemon.increment)
    }

	@IBAction func incrementChanged(_ sender: Any)
	{
		selectedIncrement = incrementSegmentedControl.selectedSegmentIndex + 1
		setDescriptionText(increment: selectedIncrement)
	}
	
	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		pokemon.increment = selectedIncrement
		pokemonService.save(pokemon: pokemon)
		performSegue(withIdentifier: "unwindFromEditIncrement", sender: self)
	}

	fileprivate func setDescriptionText(increment: Int)
	{
		switch increment
		{
		case 1:
			descriptionLabel.text = "Used for single encounters, like when soft resetting for a single Pokémon, Pokéradar chaining or chain fishing"
			break
		case 2:
			descriptionLabel.text = "Used for double hunting, like when soft resetting for static encounters on multiple systems"
		case 3:
			descriptionLabel.text = "Used for Pokéradar chaining, when space is limited and three patches of grass are the most frequent"
			break
		case 4:
			descriptionLabel.text = "Used for Pokéradar chaining, when you have plenty of space and four patches of grass are the most frequent"
			break
		case 5:
			descriptionLabel.text = "Used for generation 6(X & Y) Pokéradar chaining, where five patches of grass can shake at once, or when receiving 5 gift Pokémon per reset"
			break
		default:
			descriptionLabel.text = "Used for horde encounters, where six Pokémon appear at once"
			break
		}
	}
}
