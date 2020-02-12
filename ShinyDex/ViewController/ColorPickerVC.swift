//
//  ColorPickerVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 11/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit
import FlexColorPicker

class ColorPickerVC: CustomColorPickerViewController
{
	var primaryWasPressed: Bool!
	var currentColor: Int!
	var settingsRepository = SettingsRepository.settingsRepositorySingleton
	
	@IBOutlet weak var colorPreviewHex: ColorPreviewWithHex!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		selectedColor = UIColor(netHex: currentColor)
	}
	
	@IBAction func savePressed(_ sender: Any)
	{
		print(selectedColor.hexValue())
		
		let color = Int(selectedColor.hexValue(), radix: 16)
		
		if primaryWasPressed == nil
		{
			settingsRepository.saveTertiaryColor(tertiaryColor: color!)
		}
		else if primaryWasPressed
		{
			settingsRepository.savePrimaryColor(primaryColor: color!)
		}
		else
		{
			settingsRepository.saveSecondaryColor(secondaryColor: color!)
		}
		
		performSegue(withIdentifier: "colorPickerUnwind", sender: self)
	}
}
