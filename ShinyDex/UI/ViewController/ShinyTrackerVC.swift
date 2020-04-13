//
//  ShinyTrackerVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 20/05/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class ShinyTrackerVC: UIViewController
{
	@IBOutlet weak var gifImageView: UIImageView!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var plusButton: UIButton!
	@IBOutlet weak var minusButton: UIButton!
	@IBOutlet weak var probabilityLabel: UILabel!
	@IBOutlet weak var addToHuntButton: UIBarButtonItem!
	@IBOutlet weak var pokeballButton: UIButton!
	@IBOutlet weak var popupView: PopupView!
	@IBOutlet weak var doubleButtonsVerticalView: DoubleVerticalButtonsView!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var gifSeparatorView: UIView!
	
	var pokemon: Pokemon!
	var currentHuntNames: [String]!
	let switchStateService = SwitchStateService()
	let probabilityService = ProbabilityService()
	let oddsService = OddsService()
	var probability: Double?
	var huntState: HuntState?
	var infoPressed = false
	var setEncountersPressed = false
	let popupHandler = PopupHandler()
	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var currentHuntService: CurrentHuntService!
	var huntStateService: HuntStateService!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		hidePopupView()
		
		setUIColors()
		
		roundCorners()
		
		roundDoubleVerticalButtonsViewCorners()
		
		setFonts()
		
		setTitle()
		
		setGif()

		huntState = huntStateService.get()
	
		resolveEncounterDetails()
		
		setNumberLabelText()
		
		setPokeballButtonImage()
		
		setButtonActions()
		
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
	}
	
	fileprivate func hidePopupView()
	{
		popupView.isHidden = true
	}
	
	fileprivate func setPokeballButtonImage()
	{
		pokeballButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
	}
	
	fileprivate func setUIColors()
	{
		view.backgroundColor = colorService.getPrimaryColor()
		popupView.backgroundColor = colorService.getSecondaryColor()
		popupView.actionLabel.textColor = colorService.getTertiaryColor()
		popupView.iconImageView.tintColor = colorService.getTertiaryColor()
		
		numberLabel.backgroundColor = colorService.getSecondaryColor()
		numberLabel.textColor = colorService.getTertiaryColor()
		
		encountersLabel.backgroundColor = colorService.getSecondaryColor()
		encountersLabel.textColor = colorService.getTertiaryColor()
		
		probabilityLabel.backgroundColor = colorService.getSecondaryColor()
		probabilityLabel.textColor = colorService.getTertiaryColor()
		
		gifSeparatorView.backgroundColor = colorService.getSecondaryColor()
		
		pokeballButton.backgroundColor = colorService.getPrimaryColor()
		
		plusButton.tintColor = colorService.getTertiaryColor()
		minusButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func roundCorners()
	{
		popupView.layer.cornerRadius = 5
		
		numberLabel.layer.cornerRadius = 5
		encountersLabel.layer.cornerRadius = 5
		probabilityLabel.layer.cornerRadius = 5
		
		gifSeparatorView.layer.cornerRadius = 5
		
		pokeballButton.layer.cornerRadius = pokeballButton.bounds.width / 2
	}
	
	fileprivate func roundDoubleVerticalButtonsViewCorners()
	{
		doubleButtonsVerticalView.layer.cornerRadius = 5
	}
	
	fileprivate func setFonts()
	{
		numberLabel.font = fontSettingsService.getSmallFont()
		probabilityLabel.font = fontSettingsService.getSmallFont()
		encountersLabel.font = fontSettingsService.getSmallFont()
		popupView.actionLabel.font = fontSettingsService.getSmallFont()
	}
	
	fileprivate func setTitle()
	{
		title = pokemon.name
	}
	
	fileprivate func setGif()
	{
		gifImageView.image = UIImage.gifImageWithData(pokemon.shinyGifData, 300.0)
	}
	
	fileprivate func setButtonActions()
	{
		doubleButtonsVerticalView.infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		doubleButtonsVerticalView.updateEncountersButton.addTarget(self, action: #selector(updateEncountersPressed), for: .touchUpInside)
	}
	
	fileprivate func resolveEncounterDetails()
	{
		setProbability()
		
		setProbabilityLabelText()
		
		setEncountersLabelText()
		
		minusButton.isEnabled = minusButtonIsEnabled()
	}
	
	fileprivate func setProbability()
	{
		let encounters = pokemon.encounters
		huntState!.shinyOdds = oddsService.getShinyOdds(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, encounters)

		probability = probabilityService.getProbability(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, encounters, huntState!.shinyOdds)
	}

	fileprivate func setProbabilityLabelText()
	{
		let encounters = pokemon.encounters
		let probabilityLabelText = probabilityService.getProbabilityText(encounters: encounters, shinyOdds: huntState!.shinyOdds, probability: probability!)
		probabilityLabel.text = probabilityLabelText
	}
	
	fileprivate func setEncountersLabelText()
	{
		let labelTitle: String?
		if huntState!.generation == 4
		{
			labelTitle = " Catch Combo: "
		}
		else
		{
			labelTitle = " Encounters: "
		}
		encountersLabel.text = "\(labelTitle!)\(pokemon.encounters)"
	}
	
	fileprivate func setNumberLabelText()
	{
		numberLabel.text = " No. \(pokemon.number + 1)"
	}
	
	fileprivate func minusButtonIsEnabled() -> Bool
	{
		return pokemon.encounters != 0
	}
	
	fileprivate func addToHuntButtonIsEnabled() -> Bool
	{
		return !currentHuntNames.contains(pokemon.name)
	}

	fileprivate func resolveButtonAccess(nameList: [String], name: String) -> Bool
	{
		return !nameList.contains(name)
	}
	
	@IBAction func plusPressed(_ sender: Any)
	{
		pokemon.encounters += 1
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}
	
	@IBAction func minusPressed(_ sender: Any)
	{
		pokemon.encounters -= 1
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}
	
	@IBAction func addToHuntPressed(_ sender: Any)
	{
		currentHuntNames.append(pokemon.name)
		currentHuntService.save(currentHuntNames: currentHuntNames)
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		popupView.actionLabel.text = "\(pokemon.name) was added to current hunt."
		popupHandler.showPopup(popupView: popupView)
	}
	
	@objc fileprivate func updateEncountersPressed(_ sender: Any)
	{
		setEncountersPressed = true
		performSegue(withIdentifier: "setEncountersSegue", sender: self)
	}
	
	@IBAction func changeCaughtBallPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "shinyTrackerToModalSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if infoPressed
		{
			infoPressed = false
			
			let destVC = segue.destination as! InfoModalVC
			
			destVC.pokemon = pokemon
			destVC.huntState = huntState
			destVC.huntStateService = huntStateService
		}
		else if setEncountersPressed
		{
			setEncountersPressed = false
			
			let destVC = segue.destination as! SetEncountersModalVC
			
			destVC.pokemon = pokemon
			destVC.pokemonService = pokemonService
		}
		else
		{
			let destVC = segue.destination as! PokeballModalVC
			
			setPokeballModalProperties(pokeballModalVC: destVC)
		}
	}
	
	fileprivate func setPokeballModalProperties(pokeballModalVC: PokeballModalVC)
	{
		pokeballModalVC.pokemonService = pokemonService
		pokeballModalVC.pokemon = pokemon
	}
	
	@objc fileprivate func infoButtonPressed(_ sender: Any)
	{
		infoPressed = true
		performSegue(withIdentifier: "infoPopupSegue", sender: self)
	}
	
	@IBAction func cancel(_ unwindSegue: UIStoryboardSegue)
	{}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue)
	{
		if let sourceTVC = unwindSegue.source as? PokeballModalVC
		{
			pokemon.caughtBall = sourceTVC.pokemon.caughtBall
			
			pokeballButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		}
	}
	
	@IBAction func dismissInfo(_ unwindSegue: UIStoryboardSegue)
	{
		setProbability()
		
		setProbabilityLabelText()

		setEncountersLabelText()
	}
	
	@IBAction func saveEncounters(_ unwindSegue: UIStoryboardSegue)
	{
		let sourceVC = unwindSegue.source as! SetEncountersModalVC
		
		pokemon = sourceVC.pokemon
		
		pokemonService.save(pokemon: pokemon)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setEncountersLabelText()
	}
}
