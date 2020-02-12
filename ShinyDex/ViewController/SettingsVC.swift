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
		
		generationSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepository.getMainColor()
		
		fontSegmentedControl.backgroundColor = settingsRepository.getSecondaryColor()
		fontSegmentedControl.tintColor = settingsRepository.getMainColor()
	}
	
	fileprivate func setFonts()
	{
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: settingsRepository?.getLargeFont() as Any]

		
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
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		shinyCharmSwitch.isOn = settingsRepository.isShinyCharmActive
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		settingsRepository.setShinyOdds()
		
		shinyOddsLabel.text = "1/\(settingsRepository.shinyOdds!)"
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
		setUIColors()
		settingsRepository.saveSettings()
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
	@IBAction func editPrimaryColorPressed(_ sender: Any)
	{
		primaryWasPressed = true
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	@IBAction func editSecondaryColorPressed(_ sender: Any)
	{
		primaryWasPressed = false
		performSegue(withIdentifier: "colorPickerSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as! ColorPickerVC
		
		if primaryWasPressed!
		{
			destVC.currentColor = settingsRepository.mainColor
		}
		else
		{
			destVC.currentColor = settingsRepository.secondaryColor
		}
		
		destVC.primaryWasPressed = primaryWasPressed
	}
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue)
	{
		setUIColors()
	}
}
