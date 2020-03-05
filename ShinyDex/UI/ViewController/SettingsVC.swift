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
	var switchStateService = SwitchStateService()
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
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
	@IBOutlet weak var themFontSeparator: UIView!
	@IBOutlet weak var generationCharmSeparator: UIView!
	@IBOutlet weak var charmLureSeparator: UIView!
	@IBOutlet weak var lureSwitch: UISwitch!
	@IBOutlet weak var lureLabel: UILabel!
	@IBOutlet weak var lureOddsSeparator: UIView!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		fontSettingsService.colorService = colorService
		
		setUIColors()
		
		setFonts()
		
		roundCorners()
		
		resolveUIObjectsState()
		
		switchStateService.resolveShinyCharmSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: shinyCharmSwitch)

		switchStateService.resolveLureSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, lureSwitch: lureSwitch)
		
		setShinyOddsLabelText()
		
		setEditButtonActions()
		
		setEditButtonTexts()
    }
	
	fileprivate func setUIColors()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		
		navigationController?.navigationBar.barTintColor = colorService!.getSecondaryColor()
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		navigationController?.navigationBar.tintColor = colorService!.getTertiaryColor()
		
		view.backgroundColor = colorService!.getPrimaryColor()
		
		themeLabel.textColor = colorService!.getTertiaryColor()
		
		primaryEditButton.contentView?.backgroundColor = colorService!.getPrimaryColor()
		
		secondaryEditButton.contentView?.backgroundColor = colorService!.getSecondaryColor()
		
		tertiaryEditButton.contentView?.backgroundColor = colorService!.getTertiaryColor()
		
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor()]
		
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		generationLabel.textColor = colorService!.getTertiaryColor()
		generationSegmentedControl.backgroundColor = colorService!.getSecondaryColor()
		generationSegmentedControl.tintColor = colorService!.getPrimaryColor()
		
		shinyOddsLabel.textColor = colorService!.getTertiaryColor()
		shinyCharmLabel.textColor = colorService!.getTertiaryColor()
		shinyCharmSwitch.onTintColor = colorService!.getSecondaryColor()
		shinyCharmSwitch.thumbTintColor = colorService!.getPrimaryColor()
		
		fontLabel.textColor = colorService!.getTertiaryColor()
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		
		fontSegmentedControl.backgroundColor = colorService!.getSecondaryColor()
		fontSegmentedControl.tintColor = colorService!.getPrimaryColor()
		
		themFontSeparator.backgroundColor = colorService!.getPrimaryColor()
		generationCharmSeparator.backgroundColor = colorService!.getPrimaryColor()
		charmLureSeparator.backgroundColor = colorService!.getPrimaryColor()
		lureOddsSeparator.backgroundColor = colorService!.getPrimaryColor()

		lureLabel.textColor = colorService!.getTertiaryColor()
		lureSwitch.onTintColor = colorService!.getSecondaryColor()
		lureSwitch.thumbTintColor = colorService!.getPrimaryColor()

	}
	
	fileprivate func setFonts()
	{
		setSegementedControlFonts()
		
		themeLabel.font = fontSettingsService.getExtraLargeFont()
		
		generationLabel.font = fontSettingsService.getExtraLargeFont()
		
		shinyCharmLabel.font = fontSettingsService.getExtraLargeFont()

		lureLabel.font = fontSettingsService.getExtraLargeFont()
		
		fontLabel.font = fontSettingsService.getExtraLargeFont()
		
		shinyOddsLabel.font = fontSettingsService.getMediumFont()
		
		primaryEditButton.label.font = fontSettingsService.getXxSmallFont()
		secondaryEditButton.label.font = fontSettingsService.getXxSmallFont()
		tertiaryEditButton.label.font = fontSettingsService.getXxSmallFont()
	}
	
	fileprivate func setSegementedControlFonts()
	{
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		fontSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
	}
	
	fileprivate func roundCorners()
	{
		themesBackgroundLabel.layer.cornerRadius = 10
		generationsBackgroundLabel.layer.cornerRadius = 10
		fontBackgroundLabel.layer.cornerRadius = 10
		primaryEditButton.layer.cornerRadius = 10
		secondaryEditButton.layer.cornerRadius = 10
		tertiaryEditButton.layer.cornerRadius = 10
		themFontSeparator.layer.cornerRadius = 5
		generationCharmSeparator.layer.cornerRadius = 5
		charmLureSeparator.layer.cornerRadius = 5
	}
	
	fileprivate func resolveUIObjectsState()
	{
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		shinyCharmSwitch.isOn = settingsRepository.isShinyCharmActive

		lureSwitch.isOn = settingsRepository.isLureInUse
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
		if fontSettingsService.fontTheme == "Modern"
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
		let generation = generationSegmentedControl.selectedSegmentIndex

		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: shinyCharmSwitch)

		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: lureSwitch)
		
		settingsRepository.generation = generationSegmentedControl.selectedSegmentIndex
		
		settingsRepository.isShinyCharmActive = shinyCharmSwitch.isOn

		settingsRepository.isLureInUse = lureSwitch.isOn
		
		setShinyOddsLabelText()
		
		settingsRepository.saveSettings()
	}
	
	@IBAction func changeFontPressed(_ sender: Any)
	{
		fontSettingsService.setFont(selectedSegment: fontSegmentedControl.selectedSegmentIndex)
		fontSettingsService.save()
		setFonts()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as! ColorPickerVC
		
		if primaryWasPressed == nil
		{
			destVC.currentColor = colorService?.getTertiaryHex()
		}
		else if primaryWasPressed!
		{
			destVC.currentColor = colorService?.getPrimaryHex()
		}
		else
		{
			destVC.currentColor = colorService?.getSecondaryHex()
		}
		
		destVC.primaryWasPressed = primaryWasPressed
		destVC.fontSettingsService = fontSettingsService
		destVC.colorService = colorService
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

	@IBAction func changeIsLureInUse(_ sender: Any)
	{
		settingsRepository.changeIsLureInUseActive(isSwitchOn: lureSwitch.isOn)

		setShinyOddsLabelText()
	}
}
