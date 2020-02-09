//
//  InfoModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class InfoModalVC: UIViewController
{
	@IBOutlet weak var infoPopupView: InfoPopupView!
	
	var pokemon: Pokemon!
	var probability: Double?
	var settingsRepo: SettingsRepository!
	var oddsResolver = OddsResolver()
	var shinyOdds: Int?
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setClearBackground()
		
		roundViewCorner()
		
		setShinyOdds()
		
		resolveShinyCharmSwitchState()
		
		setButtonActions()
		
		setShinyCharmAction()
		
		setGenerationSegmentedControlAction()
		
		setInfo()
    }
	
	fileprivate func setClearBackground()
	{
		view.backgroundColor = .clear
	}
	
	fileprivate func roundViewCorner()
	{
		infoPopupView.layer.cornerRadius = 10
	}
	
	fileprivate func setShinyOdds()
	{
		shinyOdds = settingsRepo.shinyOdds
	}
	
	fileprivate func resolveShinyCharmSwitchState()
	{
		oddsResolver.resolveShinyCharmSwitchState(generation: settingsRepo.generation, shinyCharmSwitch: infoPopupView.shinyCharmSwitch)
	}
	
	fileprivate func setButtonActions()
	{
		infoPopupView.cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
		infoPopupView.saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
	}
	
	@objc fileprivate func cancelPressed()
	{
		dismiss(animated: true)
	}
	
	@objc fileprivate func savePressed()
	{
		settingsRepo?.isShinyCharmActive = infoPopupView.shinyCharmSwitch.isOn
		
		settingsRepo?.generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		
		settingsRepo.setShinyOdds()
		
		settingsRepo?.saveSettings()
		
		performSegue(withIdentifier: "infoUnwind", sender: self)
	}
	
	fileprivate func setShinyCharmAction()
	{
		infoPopupView.shinyCharmSwitch.addTarget(self, action: #selector(shinyCharmPressed), for: .touchUpInside)
	}
	
	@objc func shinyCharmPressed(sender: UISwitch!)
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		let isCharmActive = infoPopupView.shinyCharmSwitch.isOn
		
		shinyOdds = settingsRepo.getShinyOdds(currentGen: generation, isCharmActive: isCharmActive)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setShinyOddsLabelText()
	}
	
	fileprivate func setProbability()
	{
		probability = Double(pokemon.encounters) / Double(shinyOdds!) * 100
	}
	
	fileprivate func setProbabilityLabelText()
	{
		let huntIsOverOdds = pokemon.encounters > shinyOdds!
		
		if huntIsOverOdds
		{
			infoPopupView.probabilityLabel.text = " Your hunt has gone over odds."
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability!)
			
			infoPopupView.probabilityLabel.text = " Probability is \(formattedProbability)%"
		}
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		infoPopupView.shinyOddsLabel.text = " 1/\(shinyOdds!)"
	}
	
	fileprivate func setGenerationSegmentedControlAction()
	{
		infoPopupView.generationSegmentedControl.addTarget(self, action: #selector(generationChanged), for: .valueChanged)
	}
	
	@objc func generationChanged(sender: UISegmentedControl!)
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		let isCharmActive = infoPopupView.shinyCharmSwitch.isOn
		
		oddsResolver.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: infoPopupView.shinyCharmSwitch)
		
		shinyOdds = settingsRepo.getShinyOdds(currentGen: generation, isCharmActive: isCharmActive)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setShinyOddsLabelText()
	}
	
	fileprivate func setInfo()
	{
		setProbability()
		
		setProbabilityLabelText()
		
		setLabelTexts()
		
		setImages()
	}
	
	fileprivate func setLabelTexts()
	{
		infoPopupView.nameLabel.text = " \(pokemon.name)"
		
		infoPopupView.numberLabel.text = " No. \(pokemon.number)"
		
		infoPopupView.encountersLabel.text = " \(pokemon.encounters)"
		
		infoPopupView.generationLabel.text = " Generation"
		
		infoPopupView.shinyOddsLabel.text = " 1/\(shinyOdds!)"
		
		infoPopupView.shinyCharmLabel.text = " Shiny Charm"
	}
	
	fileprivate func setImages()
	{
		infoPopupView.spriteImageView.image = pokemon.shinyImage
		infoPopupView.pokeballImageView.image = UIImage(named: pokemon.caughtBall)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
