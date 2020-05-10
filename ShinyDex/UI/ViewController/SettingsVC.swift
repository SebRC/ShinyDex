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

		gameSettingsContainer.lureCell.actionSwitch.addTarget(self, action: #selector(changeIsLureInUse), for: .valueChanged)
		gameSettingsContainer.shinyCharmCell.actionSwitch.addTarget(self, action: #selector(changeIsShinyCharmActive), for: .valueChanged)
		gameSettingsContainer.masudaCell.actionSwitch.addTarget(self, action: #selector(changeIsMasudaHunting), for: .valueChanged)
		gameSettingsContainer.generationSegmentedControl.addTarget(self, action: #selector(changeGenerationPressed), for: .valueChanged)

		setUIColors()
		
		setFonts()
		
		roundCorners()

		huntState = huntStateService.get()
		
		resolveUIObjectsState()
		
		switchStateService.resolveShinyCharmSwitchState(generation: gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, shinyCharmSwitch: gameSettingsContainer.shinyCharmCell.actionSwitch)
		switchStateService.resolveLureSwitchState(generation: gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, lureSwitch: gameSettingsContainer.lureCell.actionSwitch)
		switchStateService.resolveMasudaSwitchState(generation: gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, masudaSwitch: gameSettingsContainer.masudaCell.actionSwitch)
		
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
		
		fontLabel.textColor = colorService!.getTertiaryColor()
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		fontSegmentedControl.backgroundColor = colorService!.getSecondaryColor()
		fontSegmentedControl.tintColor = colorService!.getPrimaryColor()
		themeFontSeparator.backgroundColor = colorService!.getPrimaryColor()
		themeSettingsBackgroundView.backgroundColor = colorService.getSecondaryColor()
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
		gameSettingsContainer.layer.cornerRadius = 10
		themeSettingsBackgroundView.layer.cornerRadius = 10
		primaryEditButton.layer.cornerRadius = 10
		secondaryEditButton.layer.cornerRadius = 10
		tertiaryEditButton.layer.cornerRadius = 10
		themeFontSeparator.layer.cornerRadius = 5
	}
	
	fileprivate func resolveUIObjectsState()
	{
		setFontSettingsControlSelectedSegmentIndex()
		
		setGenerationSettingsControlSelectedSegmentIndex()
		
		gameSettingsContainer.shinyCharmCell.actionSwitch.isOn = huntState!.isShinyCharmActive
		setImageViewAlpha(imageView: gameSettingsContainer.shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)

		gameSettingsContainer.lureCell.actionSwitch.isOn = huntState!.isLureInUse
		setImageViewAlpha(imageView: gameSettingsContainer.lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)

		gameSettingsContainer.masudaCell.actionSwitch.isOn = huntState!.isMasudaHunting
		setImageViewAlpha(imageView: gameSettingsContainer.masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		gameSettingsContainer.shinyOddsLabel.text = "Shiny Odds: 1/\(huntState!.shinyOdds)"
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
		gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex = huntState!.generation
	}

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool)
	{
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
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
		gameSettingsContainer.setUIColors()
		gameSettingsContainer.setCellColors()
		setAttributedFonts()
	}

	@objc fileprivate func changeIsLureInUse(_ sender: Any)
	{
		huntState!.isLureInUse = gameSettingsContainer.lureCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, gameSettingsContainer.shinyCharmCell.actionSwitch.isOn, huntState!.isLureInUse, gameSettingsContainer.masudaCell.actionSwitch.isOn)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsShinyCharmActive(_ sender: Any)
	{
		huntState?.isShinyCharmActive = gameSettingsContainer.shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, huntState!.isShinyCharmActive, gameSettingsContainer.lureCell.actionSwitch.isOn, gameSettingsContainer.masudaCell.actionSwitch.isOn)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsMasudaHunting(_ sender: Any)
	{
		huntState?.isMasudaHunting = gameSettingsContainer.masudaCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex, gameSettingsContainer.shinyCharmCell.actionSwitch.isOn, gameSettingsContainer.lureCell.actionSwitch.isOn, huntState!.isMasudaHunting)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeGenerationPressed(_ sender: Any)
	{
		let generation = gameSettingsContainer.generationSegmentedControl.selectedSegmentIndex

		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: gameSettingsContainer.shinyCharmCell.actionSwitch)
		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: gameSettingsContainer.lureCell.actionSwitch)
		switchStateService.resolveMasudaSwitchState(generation: generation, masudaSwitch: gameSettingsContainer.masudaCell.actionSwitch)

		huntState!.generation = generation

		huntState!.isShinyCharmActive = gameSettingsContainer.shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)

		huntState!.isLureInUse = gameSettingsContainer.lureCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)

		huntState!.isMasudaHunting = gameSettingsContainer.masudaCell.actionSwitch.isOn
		setImageViewAlpha(imageView: gameSettingsContainer.masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)

		huntState!.shinyOdds = oddsService.getShinyOdds(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, huntState!.isMasudaHunting)

		setShinyOddsLabelText()

		huntStateService.save(huntState!)
	}
}
