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
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!

	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var colorPreviewHex: ColorPreviewWithHex!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		selectedColor = UIColor(netHex: currentColor)
		
		view.backgroundColor = .white
		
		saveButton.layer.cornerRadius = 10
		
		cancelButton.layer.cornerRadius = 10
		
		titleLabel.textColor = .black
		
		titleLabel.font = fontSettingsService.getMediumFont()
		
		saveButton.titleLabel?.font = fontSettingsService.getExtraSmallFont()
		
		cancelButton.titleLabel?.font = fontSettingsService.getExtraSmallFont()
		
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
		let color = Int(selectedColor.hexValue(), radix: 16)
		
		if primaryWasPressed == nil
		{
			colorService.save(hex: color!, name: "tertiaryColor")
		}
		else if primaryWasPressed
		{
			colorService.save(hex: color!, name: "primaryColor")
		}
		else
		{
			colorService.save(hex: color!, name: "secondaryColor")
		}
		
		performSegue(withIdentifier: "colorPickerUnwind", sender: self)
	}
	
	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}
