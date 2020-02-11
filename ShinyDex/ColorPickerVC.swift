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
		
        // Do any additional setup after loading the view.
    }
	
	@IBAction func savePressed(_ sender: Any)
	{
		print(selectedColor.hexValue())
		
		let color = Int(selectedColor.hexValue(), radix: 16)
		
		print(color)
		
		if primaryWasPressed
		{
			settingsRepository.saveMainColor(mainColor: color!)
		}
		else
		{
			settingsRepository.saveSecondaryColor(secondaryColor: color!)
		}
	}
}
