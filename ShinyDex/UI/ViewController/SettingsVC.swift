//
//  SettingsVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 21/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController
{
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var theme = Theme.Primary

	@IBOutlet weak var fontSegmentedControl: UISegmentedControl!
	@IBOutlet weak var themeLabel: UILabel!
	@IBOutlet weak var fontLabel: UILabel!
	@IBOutlet weak var primaryEditButton: ButtonIconRight!
	@IBOutlet weak var secondaryEditButton: ButtonIconRight!
	@IBOutlet weak var tertiaryEditButton: ButtonIconRight!
	@IBOutlet weak var themeFontSeparator: UIView!
	@IBOutlet weak var themeSettingsBackgroundView: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!

	override func viewDidLoad()
	{
        super.viewDidLoad()
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: themeSettingsBackgroundView.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true

		setUIColors()
		
		setFonts()
		
		roundCorners()
		
		setFontSettingsControlSelectedSegmentIndex()
		
		setEditButtonActions()
		
		setEditButtonTexts()
    }
	
	fileprivate func setUIColors()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		
		navigationController?.navigationBar.barTintColor = colorService!.getPrimaryColor()
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		navigationController?.navigationBar.tintColor = colorService!.getTertiaryColor()
		
		view.backgroundColor = colorService!.getSecondaryColor()
		
		themeLabel.textColor = colorService!.getTertiaryColor()
		
		primaryEditButton.contentView?.backgroundColor = colorService!.getSecondaryColor()
		
		secondaryEditButton.contentView?.backgroundColor = colorService!.getPrimaryColor()
		
		tertiaryEditButton.contentView?.backgroundColor = colorService!.getTertiaryColor()
		
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor()]
		
		fontLabel.textColor = colorService!.getTertiaryColor()
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		fontSegmentedControl.backgroundColor = colorService!.getPrimaryColor()
		fontSegmentedControl.tintColor = colorService!.getSecondaryColor()
		themeFontSeparator.backgroundColor = colorService!.getSecondaryColor()
		themeSettingsBackgroundView.backgroundColor = colorService.getPrimaryColor()
	}
	
	fileprivate func setFonts()
	{
		setAttributedFonts()
		themeLabel.font = fontSettingsService.getExtraLargeFont()
		fontLabel.font = fontSettingsService.getExtraLargeFont()
		primaryEditButton.label.font = fontSettingsService.getXxSmallFont()
		secondaryEditButton.label.font = fontSettingsService.getXxSmallFont()
		tertiaryEditButton.label.font = fontSettingsService.getXxSmallFont()
		gameSettingsContainer.setFonts()
		gameSettingsContainer.setCellFonts()
	}
	
	fileprivate func setAttributedFonts()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		fontSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
	}
	
	fileprivate func roundCorners()
	{
		gameSettingsContainer.layer.cornerRadius = CornerRadius.Standard.rawValue
		themeSettingsBackgroundView.layer.cornerRadius = CornerRadius.Standard.rawValue
		primaryEditButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		secondaryEditButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		tertiaryEditButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		themeFontSeparator.layer.cornerRadius = CornerRadius.Standard.rawValue
	}
	
	fileprivate func setEditButtonActions()
	{
		primaryEditButton.button.addTarget(self, action: #selector(primaryEditButtonPressed), for: .touchUpInside)
		secondaryEditButton.button.addTarget(self, action: #selector(secondaryEditButtonPressed), for: .touchUpInside)
		tertiaryEditButton.button.addTarget(self, action: #selector(tertiaryEditButtonPressed), for: .touchUpInside)
	}
	
	fileprivate func setEditButtonTexts()
	{
		primaryEditButton.label.text = "Primary"
		secondaryEditButton.label.text = "Secondary"
		tertiaryEditButton.label.text = "Tertiary"
	}
	
	fileprivate func setFontSettingsControlSelectedSegmentIndex()
	{
		if fontSettingsService.getFontThemeName() == FontThemeName.Modern.description
		{
			fontSegmentedControl.selectedSegmentIndex = 0
		}
		else
		{
			fontSegmentedControl.selectedSegmentIndex = 1
		}
	}
	
	@IBAction func changeFontPressed(_ sender: Any)
	{
		let fontThemeName = fontSegmentedControl.selectedSegmentIndex == 0 ? FontThemeName.Modern.description : FontThemeName.Retro.description
		fontSettingsService.save(fontThemeName: fontThemeName)
		setFonts()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as! ColorPickerVC
		
		if theme == .Tertiary
		{
			destVC.currentColor = colorService?.getTertiaryHex()
		}
		else if theme == .Primary
		{
			destVC.currentColor = colorService?.getPrimaryHex()
		}
		else
		{
			destVC.currentColor = colorService?.getSecondaryHex()
		}
		
		destVC.theme = theme
		destVC.fontSettingsService = fontSettingsService
		destVC.colorService = colorService
	}
	
	@objc fileprivate func primaryEditButtonPressed()
	{
		theme = .Primary
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@objc fileprivate func secondaryEditButtonPressed()
	{
		theme = .Secondary
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@objc fileprivate func tertiaryEditButtonPressed()
	{
		theme = .Tertiary
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		setUIColors()
		gameSettingsContainer.setUIColors()
		gameSettingsContainer.setCellColors()
		setFonts()
	}
}
