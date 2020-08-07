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

	var colorService: ColorService!
	var fontSettingsService: FontSettingsService!
	var huntStateService: HuntStateService!
	var huntState: HuntState!
	var selectedIncrement = 1
	


	override func viewDidLoad()
	{
        super.viewDidLoad()
		selectedIncrement = huntState.increment

		titleLabel.font = fontSettingsService.getExtraSmallFont()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.font = fontSettingsService.getExtraSmallFont()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		modalView.layer.cornerRadius = CornerRadius.Standard.rawValue
		modalView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.titleLabel?.font = fontSettingsService.getSmallFont()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService?.getTertiaryColor(), for: .normal)
		cancelButton.titleLabel?.font = fontSettingsService.getSmallFont()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService?.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()

		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor()]

		incrementSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		incrementSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		incrementSegmentedControl.backgroundColor = colorService!.getPrimaryColor()
		incrementSegmentedControl.tintColor = colorService!.getSecondaryColor()
		incrementSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)

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
		performSegue(withIdentifier: "incrementUnwind", sender: self)
	}

	fileprivate func setDescriptionText(increment: Int)
	{
		switch increment
		{
		case 0, 1:
			descriptionLabel.text = "Used for single encounters, like when soft resetting, Pokéradar chaining or chain fishing"
			break
		case 3:
			descriptionLabel.text = "Used for Pokéradar chaining, when space is limited and three patches of grass are the most frequent"
			break
		case 4:
			descriptionLabel.text = "Used for Pokéradar chaining, when you have plenty of space and four patches of grass are the most frequent"
			break
		case 5:
			descriptionLabel.text = "Used for generation 6(X & Y) Pokéradar chaining, where five patches of grass can shake at once"
			break
		default:
			descriptionLabel.text = "Used for horde encounters, where six Pokémon appear at once"
			break
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
