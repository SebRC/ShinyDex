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
	@IBOutlet weak var settingsControl: UISegmentedControl!
	var settingsRepo: SettingsRepository!
	var oddsResolver = OddsResolver()
	
	@IBOutlet weak var generationsBackgroundLabel: UILabel!
	@IBOutlet weak var themeSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmBackgroundLabel: UILabel!
	@IBOutlet weak var shinyCharmSwitch: UISwitch!
	@IBOutlet weak var themesBackgroundLabel: UILabel!
	@IBOutlet weak var generationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmLabel: UILabel!
	@IBOutlet weak var fontSegmentedControl: UISegmentedControl!
	@IBOutlet weak var themeLabel: UILabel!
	@IBOutlet weak var generationLabel: UILabel!
	@IBOutlet weak var shinyOddsBackgroundLabel: UILabel!
	@IBOutlet weak var shinyOddsLabel: UILabel!
	@IBOutlet weak var shinyOddsTitleLabel: UILabel!
	@IBOutlet weak var fontLabel: UILabel!
	@IBOutlet weak var fontBackgroundLabel: UILabel!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setUIColors()
		
		setFonts()
		
		roundBackgroundCorners()
		
		resolveUIObjectsState()
		
		oddsResolver.resolveShinyCharmSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: shinyCharmSwitch)
		
		setShinyOddsLabelText()
    }
	
	fileprivate func setUIColors()
	{
		navigationController?.navigationBar.barTintColor = settingsRepo.getSecondaryColor()
		view.backgroundColor = settingsRepo.getMainColor()
		
		shinyCharmSwitch.onTintColor = settingsRepo.getSecondaryColor()
		shinyCharmSwitch.thumbTintColor = settingsRepo.getMainColor()
		
		themeSegmentedControl.backgroundColor = settingsRepo.getSecondaryColor()
		themeSegmentedControl.tintColor = settingsRepo.getMainColor()
		
		generationSegmentedControl.backgroundColor = settingsRepo.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepo.getMainColor()
		
		fontSegmentedControl.backgroundColor = settingsRepo.getSecondaryColor()
		fontSegmentedControl.tintColor = settingsRepo.getMainColor()
	}
	
	fileprivate func setFonts()
	{
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: settingsRepo?.getLargeFont() as Any]
		
		themeSegmentedControl.setTitleTextAttributes(settingsRepo.getFontAsNSAttibutedStringKey(fontSize: settingsRepo.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		generationSegmentedControl.setTitleTextAttributes(settingsRepo.getFontAsNSAttibutedStringKey( fontSize: settingsRepo.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		fontSegmentedControl.setTitleTextAttributes(settingsRepo.getFontAsNSAttibutedStringKey(fontSize: settingsRepo.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		themeLabel.font = settingsRepo.getExtraLargeFont()
		
		generationLabel.font = settingsRepo.getExtraLargeFont()
		
		shinyCharmLabel.font = settingsRepo.getExtraLargeFont()
		
		fontLabel.font = settingsRepo.getExtraLargeFont()
		
		shinyOddsLabel.font = settingsRepo.getMediumFont()
		
		shinyOddsTitleLabel.font = settingsRepo.getExtraLargeFont()
	}
	
	
	fileprivate func roundBackgroundCorners()
	{
		themesBackgroundLabel.layer.cornerRadius = 10
		shinyCharmBackgroundLabel.layer.cornerRadius = 10
		generationsBackgroundLabel.layer.cornerRadius = 10
		fontBackgroundLabel.layer.cornerRadius = 10
		shinyOddsBackgroundLabel.layer.cornerRadius = 10
	}
	
	fileprivate func resolveUIObjectsState()
	{
		setThemeControlSelectedSegmentIndex()
		
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		shinyCharmSwitch.isOn = settingsRepo.isShinyCharmActive
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		settingsRepo.setShinyOdds()
		
		shinyOddsLabel.text = "1/\(settingsRepo.shinyOdds!)"
	}
	
	fileprivate func setThemeControlSelectedSegmentIndex()
	{
		if settingsRepo.settingsName == "Light"
		{
			settingsControl.selectedSegmentIndex = 0
		}
		else if settingsRepo?.settingsName == "Dark"
		{
			settingsControl.selectedSegmentIndex = 1
		}
		else
		{
			settingsControl.selectedSegmentIndex = 2
		}
	}
	
	fileprivate func setFontSettingsControlSelectedSegmentIndex()
	{
		if settingsRepo.fontTheme == "Modern"
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
		generationSegmentedControl.selectedSegmentIndex = settingsRepo.generation
	}
    
	@IBAction func changeTheme(_ sender: Any)
	{
		setUITheme()
		setUIColors()
		settingsRepo.saveSettings()
	}
	
	fileprivate func setUITheme()
	{
		if(settingsControl.selectedSegmentIndex == 0)
		{
			setLightTheme()
		}
		else if(settingsControl.selectedSegmentIndex == 1)
		{
			setDarkTheme()
		}
		else
		{
			setClassicTheme()
		}
	}
	
	fileprivate func setLightTheme()
	{
		settingsRepo.mainColor = 0xABE8ED
		settingsRepo.secondaryColor = 0x03C4FB
		settingsRepo.settingsName = "Light"
	}
	
	fileprivate func setDarkTheme()
	{
		settingsRepo.mainColor = 0x646464
		settingsRepo.secondaryColor = 0x323232
		settingsRepo.settingsName = "Dark"
	}
	
	fileprivate func setClassicTheme()
	{
		settingsRepo.mainColor = 0xABE8ED
		settingsRepo.secondaryColor = 0xFE493D
		settingsRepo.settingsName = "Classic"
	}
	
	@IBAction func changeIsShinyCharmActive(_ sender: Any)
	{
		settingsRepo.changeIsShinyCharmActive(isSwitchOn: shinyCharmSwitch.isOn)
		
		setShinyOddsLabelText()
	}
	
	@IBAction func changeGenerationPressed(_ sender: Any)
	{
		oddsResolver.resolveShinyCharmSwitchState(generation: generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: shinyCharmSwitch)
		
		settingsRepo.generation = generationSegmentedControl.selectedSegmentIndex
		
		setShinyOddsLabelText()
		
		settingsRepo.saveSettings()
	}
	
	@IBAction func changeFontPressed(_ sender: Any)
	{
		settingsRepo.setGlobalFont(selectedSegment: fontSegmentedControl.selectedSegmentIndex)
		setFonts()
	}
}
