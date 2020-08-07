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
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonBackgroundView: UIView!
	@IBOutlet weak var buttonSeparatorView: UIView!
	@IBOutlet weak var incrementSegmentedControl: UISegmentedControl!

	var colorService: ColorService!
	var fontSettingsService: FontSettingsService!
	var huntStateService: HuntStateService!
	var huntState: HuntState!
	var selectedIncrement = 1
	


	override func viewDidLoad()
	{
        super.viewDidLoad()
		selectedIncrement = huntState.increment

		switch huntState.increment
		{
		case 0, 1:
			incrementSegmentedControl.selectedSegmentIndex = 0
			break
		case 3:
			incrementSegmentedControl.selectedSegmentIndex = 1
			break
		case 4:
			incrementSegmentedControl.selectedSegmentIndex = 2
			break
		case 5:
			incrementSegmentedControl.selectedSegmentIndex = 3
			break
		default:
			incrementSegmentedControl.selectedSegmentIndex = 4
			break
		}

		setDescriptionText(increment: huntState.increment)
    }

	@IBAction func incrementChanged(_ sender: Any)
	{
		switch incrementSegmentedControl.selectedSegmentIndex
		{
		case 0:
			selectedIncrement = 1
			break
		case 1:
			selectedIncrement = 3
			break
		case 2:
			selectedIncrement = 4
			break
		case 3:
			selectedIncrement = 5
			break
		default:
			selectedIncrement = 6
			break
		}
		setDescriptionText(increment: selectedIncrement)
	}
	
	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}

	@IBAction func confirmPressed(_ sender: Any)
	{
		huntState.increment = selectedIncrement
		huntStateService.save(huntState)
		dismiss(animated: true)
	}

	fileprivate func setDescriptionText(increment: Int)
	{
		switch increment
		{
		case 0, 1:
			descriptionLabel.text = "Used for single encounters, like when soft resetting, Pokéradar chaining or chain fishing"
			break
		case 3:
			descriptionLabel.text = "Used for Pokéradar chaining, when space is limited and three patches are the most frequent"
			break
		case 4:
			descriptionLabel.text = "Used for Pokéradar chaining, when you have plenty of space and four patches are the most frequent"
			break
		case 5:
			descriptionLabel.text = "Used for generation 6(X & Y) Pokéradar chaining, where five patches of grass can shake at once"
			break
		default:
			descriptionLabel.text = "Used for horde encounters, where six Pokémon appear at once"
			break
		}
	}
}
