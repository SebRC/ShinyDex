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
	var hunts: [Hunt]!
	let switchStateService = SwitchStateService()
	let probabilityService = ProbabilityService()
	let oddsService = OddsService()
	var probability: Double?
	var huntState: HuntState?
	var infoPressed = false
	var setEncountersPressed = false
	var isAddingToHunt = false
	let popupHandler = PopupHandler()
	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntService: HuntService!
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
		popupView.layer.cornerRadius = 10
		numberLabel.layer.cornerRadius = 10
		encountersLabel.layer.cornerRadius = 10
		probabilityLabel.layer.cornerRadius = 10
		gifSeparatorView.layer.cornerRadius = 10
		pokeballButton.layer.cornerRadius = pokeballButton.bounds.width / 2
	}
	
	fileprivate func roundDoubleVerticalButtonsViewCorners()
	{
		doubleButtonsVerticalView.layer.cornerRadius = 10
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
		huntState!.shinyOdds = oddsService.getShinyOdds(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, huntState!.isMasudaHunting, encounters)

		probability = probabilityService.getProbability(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, huntState!.isMasudaHunting, encounters, huntState!.shinyOdds)
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
		return !pokemon.isBeingHunted
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
		if hunts.isEmpty
		{
			huntService.createNewHuntWithPokemon(hunts: &hunts, pokemon: pokemon!)
			popupView.actionLabel.text = "\(pokemon!.name) was added to New Hunt."
			popupHandler.showPopup(popupView: popupView)
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else if hunts.count == 1
		{
			huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: pokemon!)
			popupView.actionLabel.text = "\(pokemon!.name) was added to \(hunts[0].name)."
			popupHandler.showPopup(popupView: popupView)
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else
		{
			isAddingToHunt = true
			performSegue(withIdentifier: "shinyTrackerToHuntPickerSegue", sender: self)
		}
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
		else if isAddingToHunt
		{
			isAddingToHunt = false
			let destVC = segue.destination as! HuntPickerModalVC
			destVC.huntService = huntService
			destVC.pokemonService = pokemonService
			destVC.fontSettingsService = fontSettingsService
			destVC.colorService = colorService
			destVC.hunts = hunts
			destVC.pokemon = pokemon
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

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue)
	{
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		let source = unwindSegue.source as! HuntPickerModalVC
		let huntName = source.pickedHuntName
		popupView.actionLabel.text = "\(pokemon!.name) was added to \(huntName!)."
		popupHandler.showPopup(popupView: popupView)
	}
}
