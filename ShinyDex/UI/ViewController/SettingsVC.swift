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
	var switchStateService = SwitchStateService()
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntStateService: HuntStateService!
	var oddsService = OddsService()
	var primaryWasPressed: Bool?
	var huntState: HuntState?
	
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
	@IBOutlet weak var lureImageView: UIImageView!
	@IBOutlet weak var shinyCharmImageView: UIImageView!
	@IBOutlet weak var lureHelpTextLabel: UILabel!
	@IBOutlet weak var shinyCharmHelpTextLabel: UILabel!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setUIColors()
		
		setFonts()
		
		roundCorners()

		huntState = huntStateService.get()
		
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
		shinyCharmHelpTextLabel.textColor = colorService!.getTertiaryColor()
		shinyCharmHelpTextLabel.alpha = 0.7
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
		lureHelpTextLabel.textColor = colorService.getTertiaryColor()
		lureHelpTextLabel.alpha = 0.7
		lureSwitch.onTintColor = colorService!.getSecondaryColor()
		lureSwitch.thumbTintColor = colorService!.getPrimaryColor()

	}
	
	fileprivate func setFonts()
	{
		setSegementedControlFonts()
		
		themeLabel.font = fontSettingsService.getExtraLargeFont()
		
		generationLabel.font = fontSettingsService.getExtraLargeFont()
		
		shinyCharmLabel.font = fontSettingsService.getMediumFont()
		shinyCharmHelpTextLabel.font = fontSettingsService.getXxSmallFont()

		lureLabel.font = fontSettingsService.getMediumFont()
		lureHelpTextLabel.font = fontSettingsService.getXxSmallFont()
		
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
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		fontSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
	}
	
	fileprivate func roundCorners()
	{
		themesBackgroundLabel.layer.cornerRadius = 10
		generationsBackgroundLabel.layer.cornerRadius = 10
		fontBackgroundLabel.layer.cornerRadius = 10
		primaryEditButton.layer.cornerRadius = 10
		secondaryEditButton.layer.cornerRadius = 10
		tertiaryEditButton.layer.cornerRadius = 10
		themFontSeparator.layer.cornerRadius = 10
		generationCharmSeparator.layer.cornerRadius = 10
		charmLureSeparator.layer.cornerRadius = 10
	}
	
	fileprivate func resolveUIObjectsState()
	{
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		shinyCharmSwitch.isOn = huntState!.isShinyCharmActive
		setImageViewAlpha(imageView: shinyCharmImageView, isSwitchOn: shinyCharmSwitch.isOn)

		lureSwitch.isOn = huntState!.isLureInUse
		setImageViewAlpha(imageView: lureImageView, isSwitchOn: lureSwitch.isOn)
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		shinyOddsLabel.text = "Shiny Odds: 1/\(huntState!.shinyOdds)"
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
	
	fileprivate func setGenerationSettingsControlSelectedSegmentIndex()
	{
		generationSegmentedControl.selectedSegmentIndex = huntState!.generation
	}
	
	@IBAction func changeIsShinyCharmActive(_ sender: Any)
	{
		huntState?.isShinyCharmActive = shinyCharmSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmImageView, isSwitchOn: shinyCharmSwitch.isOn)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch.isOn, lureSwitch.isOn)
		setShinyOddsLabelText()
	}

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool)
	{
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
	}
	
	@IBAction func changeGenerationPressed(_ sender: Any)
	{
		let generation = generationSegmentedControl.selectedSegmentIndex

		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: shinyCharmSwitch)

		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: lureSwitch)
		
		huntState!.generation = generationSegmentedControl.selectedSegmentIndex
		
		huntState!.isShinyCharmActive = shinyCharmSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmImageView, isSwitchOn: shinyCharmSwitch.isOn)

		huntState!.isLureInUse = lureSwitch.isOn
		setImageViewAlpha(imageView: lureImageView, isSwitchOn: lureSwitch.isOn)

		huntState!.shinyOdds = oddsService.getShinyOdds(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse)
		
		setShinyOddsLabelText()
		
		huntStateService.save(huntState!)
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
		huntState!.isLureInUse = lureSwitch.isOn
		setImageViewAlpha(imageView: lureImageView, isSwitchOn: lureSwitch.isOn)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch.isOn, lureSwitch.isOn)
		setShinyOddsLabelText()
	}
}
