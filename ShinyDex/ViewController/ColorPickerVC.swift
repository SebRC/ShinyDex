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
	@IBOutlet weak var saveButton: UIButton!
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var colorPreviewHex: ColorPreviewWithHex!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		selectedColor = UIColor(netHex: currentColor)
		
		view.backgroundColor = .white
		
		saveButton.layer.cornerRadius = 5
		
		cancelButton.layer.cornerRadius = 5
		
		titleLabel.textColor = .black
		
		titleLabel.font = settingsRepository.getMediumFont()
		
		saveButton.titleLabel?.font = settingsRepository.getExtraSmallFont()
		
		cancelButton.titleLabel?.font = settingsRepository.getExtraSmallFont()
		
		if primaryWasPressed == nil
		{
			titleLabel.text = "Tertiary Color"
		}
		else if primaryWasPressed
		{
			titleLabel.text = "Primary Color"
		}
		else
		{
			titleLabel.text = "Secondary Color"
		}
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
	
	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}
