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
	var settingsRepository: SettingsRepository!
	var oddsResolver = OddsResolver()
	var primaryWasPressed: Bool?
	
	@IBOutlet weak var generationsBackgroundLabel: UILabel!
	@IBOutlet weak var shinyCharmSwitch: UISwitch!
	@IBOutlet weak var themesBackgroundLabel: UILabel!
	@IBOutlet weak var generationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmLabel: UILabel!
	@IBOutlet weak var fontSegmentedControl: UISegmentedControl!
	@IBOutlet weak var themeLabel: UILabel!
	@IBOutlet weak var generationLabel: UILabel!
	@IBOutlet weak var shinyOddsLabel: UILabel!
	@IBOutlet weak var fontLabel: UILabel!
	@IBOutlet weak var fontBackgroundLabel: UILabel!
	@IBOutlet weak var primaryEditButton: ButtonIconRight!
	@IBOutlet weak var secondaryEditButton: ButtonIconRight!
	@IBOutlet weak var tertiaryEditButton: ButtonIconRight!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setUIColors()
		
		setFonts()
		
		roundBackgroundCorners()
		
		resolveUIObjectsState()
		
		oddsResolver.resolveShinyCharmSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: shinyCharmSwitch)
		
		setShinyOddsLabelText()
		
		setEditButtonActions()
		
		setEditButtonTexts()
    }
	
	fileprivate func setUIColors()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: settingsRepository.getTertiaryColor(),
			NSAttributedString.Key.font: settingsRepository.getLargeFont()
		]
		
		navigationController?.navigationBar.barTintColor = settingsRepository.getSecondaryColor()
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		navigationController?.navigationBar.tintColor = settingsRepository?.getTertiaryColor()
		
		view.backgroundColor = settingsRepository.getPrimaryColor()
		
		themeLabel.textColor = settingsRepository.getTertiaryColor()
		
		primaryEditButton.contentView?.backgroundColor = settingsRepository.getPrimaryColor()
		
		secondaryEditButton.contentView?.backgroundColor = settingsRepository.getSecondaryColor()
		
		tertiaryEditButton.contentView?.backgroundColor = settingsRepository.getTertiaryColor()
		
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: settingsRepository.getTertiaryColor()]
		
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		generationLabel.textColor = settingsRepository.getTertiaryColor()
		generationSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepository.getPrimaryColor()
		
		shinyOddsLabel.textColor = settingsRepository.getTertiaryColor()
		shinyCharmLabel.textColor = settingsRepository.getTertiaryColor()
		shinyCharmSwitch.onTintColor = settingsRepository.getSecondaryColor()
		shinyCharmSwitch.thumbTintColor = settingsRepository.getPrimaryColor()
		
		fontLabel.textColor = settingsRepository.getTertiaryColor()
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		
		fontSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		fontSegmentedControl.tintColor = settingsRepository.getPrimaryColor()
	}
	
	fileprivate func setFonts()
	{
		setSegementedControlFonts()
		
		themeLabel.font = settingsRepository.getExtraLargeFont()
		
		generationLabel.font = settingsRepository.getExtraLargeFont()
		
		shinyCharmLabel.font = settingsRepository.getExtraLargeFont()
		
		fontLabel.font = settingsRepository.getExtraLargeFont()
		
		shinyOddsLabel.font = settingsRepository.getMediumFont()
		
		primaryEditButton.label.font = settingsRepository.getXxSmallFont()
		secondaryEditButton.label.font = settingsRepository.getXxSmallFont()
		tertiaryEditButton.label.font = settingsRepository.getXxSmallFont()
	}
	
	fileprivate func setSegementedControlFonts()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: settingsRepository.getTertiaryColor(),
			NSAttributedString.Key.font: settingsRepository.getLargeFont()
		]
		
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		generationSegmentedControl.setTitleTextAttributes(settingsRepository.getFontAsNSAttibutedStringKey( fontSize: settingsRepository.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		fontSegmentedControl.setTitleTextAttributes(settingsRepository.getFontAsNSAttibutedStringKey(fontSize: settingsRepository.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
	}
	
	
	fileprivate func roundBackgroundCorners()
	{
		themesBackgroundLabel.layer.cornerRadius = 10
		generationsBackgroundLabel.layer.cornerRadius = 10
		fontBackgroundLabel.layer.cornerRadius = 10
		primaryEditButton.layer.cornerRadius = 10
		secondaryEditButton.layer.cornerRadius = 10
		tertiaryEditButton.layer.cornerRadius = 10
	}
	
	fileprivate func resolveUIObjectsState()
	{
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		shinyCharmSwitch.isOn = settingsRepository.isShinyCharmActive
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		settingsRepository.setShinyOdds()
		
		shinyOddsLabel.text = "Shiny Odds: 1/\(settingsRepository.shinyOdds!)"
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
		if settingsRepository.fontTheme == "Modern"
		{
			fontSegmentedControl.selectedSegmentIndex = 0
		}
		else
		{
			fontSegmentedControl.selectedSegmentIndex = 1
		}
	}
	
	fileprivate func setGenerationSettingsControlSelectedSegmentIndex()
	{
		generationSegmentedControl.selectedSegmentIndex = settingsRepository.generation
	}
	
	@IBAction func changeIsShinyCharmActive(_ sender: Any)
	{
		settingsRepository.changeIsShinyCharmActive(isSwitchOn: shinyCharmSwitch.isOn)
		
		setShinyOddsLabelText()
	}
	
	@IBAction func changeGenerationPressed(_ sender: Any)
	{
		oddsResolver.resolveShinyCharmSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: shinyCharmSwitch)
		
		settingsRepository.generation = generationSegmentedControl.selectedSegmentIndex
		
		settingsRepository.isShinyCharmActive = shinyCharmSwitch.isOn
		
		setShinyOddsLabelText()
		
		settingsRepository.saveSettings()
	}
	
	@IBAction func changeFontPressed(_ sender: Any)
	{
		settingsRepository.setGlobalFont(selectedSegment: fontSegmentedControl.selectedSegmentIndex)
		setFonts()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as! ColorPickerVC
		
		if primaryWasPressed == nil
		{
			destVC.currentColor = settingsRepository.tertiaryColor
		}
		else if primaryWasPressed!
		{
			destVC.currentColor = settingsRepository.primaryColor
		}
		else
		{
			destVC.currentColor = settingsRepository.secondaryColor
		}
		
		destVC.primaryWasPressed = primaryWasPressed
	}
	
	@objc fileprivate func primaryEditButtonPressed()
	{
		primaryWasPressed = true
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@objc fileprivate func secondaryEditButtonPressed()
	{
		primaryWasPressed = false
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@objc fileprivate func tertiaryEditButtonPressed()
	{
		primaryWasPressed = nil
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		setUIColors()
		setSegementedControlFonts()
	}
}
