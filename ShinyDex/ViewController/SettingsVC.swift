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
	var settingsRepository: SettingsRepository!
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
		navigationController?.navigationBar.barTintColor = settingsRepository.getSecondaryColor()
		view.backgroundColor = settingsRepository.getMainColor()
		
		shinyCharmSwitch.onTintColor = settingsRepository.getSecondaryColor()
		shinyCharmSwitch.thumbTintColor = settingsRepository.getMainColor()
		
		themeSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		themeSegmentedControl.tintColor = settingsRepository.getMainColor()
		
		generationSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepository.getMainColor()
		
		fontSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		fontSegmentedControl.tintColor = settingsRepository.getMainColor()
	}
	
	fileprivate func setFonts()
	{
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: settingsRepository?.getLargeFont() as Any]
		
		themeSegmentedControl.setTitleTextAttributes(settingsRepository.getFontAsNSAttibutedStringKey(fontSize: settingsRepository.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		generationSegmentedControl.setTitleTextAttributes(settingsRepository.getFontAsNSAttibutedStringKey( fontSize: settingsRepository.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		fontSegmentedControl.setTitleTextAttributes(settingsRepository.getFontAsNSAttibutedStringKey(fontSize: settingsRepository.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		themeLabel.font = settingsRepository.getExtraLargeFont()
		
		generationLabel.font = settingsRepository.getExtraLargeFont()
		
		shinyCharmLabel.font = settingsRepository.getExtraLargeFont()
		
		fontLabel.font = settingsRepository.getExtraLargeFont()
		
		shinyOddsLabel.font = settingsRepository.getMediumFont()
		
		shinyOddsTitleLabel.font = settingsRepository.getExtraLargeFont()
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
		
		shinyCharmSwitch.isOn = settingsRepository.isShinyCharmActive
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		settingsRepository.setShinyOdds()
		
		shinyOddsLabel.text = "1/\(settingsRepository.shinyOdds!)"
	}
	
	fileprivate func setThemeControlSelectedSegmentIndex()
	{
		if settingsRepository.settingsName == "Light"
		{
			settingsControl.selectedSegmentIndex = 0
		}
		else if settingsRepository?.settingsName == "Dark"
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
    
	@IBAction func changeTheme(_ sender: Any)
	{
		setUITheme()
		setUIColors()
		settingsRepository.saveSettings()
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
		settingsRepository.mainColor = 0xABE8ED
		settingsRepository.secondaryColor = 0x03C4FB
		settingsRepository.settingsName = "Light"
	}
	
	fileprivate func setDarkTheme()
	{
		settingsRepository.mainColor = 0x646464
		settingsRepository.secondaryColor = 0x323232
		settingsRepository.settingsName = "Dark"
	}
	
	fileprivate func setClassicTheme()
	{
		settingsRepository.mainColor = 0xABE8ED
		settingsRepository.secondaryColor = 0xFE493D
		settingsRepository.settingsName = "Classic"
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
		
		setShinyOddsLabelText()
		
		settingsRepository.saveSettings()
	}
	
	@IBAction func changeFontPressed(_ sender: Any)
	{
		settingsRepository.setGlobalFont(selectedSegment: fontSegmentedControl.selectedSegmentIndex)
		setFonts()
	}
}
