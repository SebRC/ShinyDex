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
	var resolver = Resolver()
	var oddsResolver = OddsResolver()
	var probability: Double?
	var shinyProbability: Int!
	var infoPressed = false
	var setEncountersPressed = false
	let popupHandler = PopupHandler()
	var pokemonRepository: PokemonRepository!
	var settingsRepository: SettingsRepository!
	var currentHuntRepository: CurrentHuntRepository!
	
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
		view.backgroundColor = settingsRepository.getPrimaryColor()
		popupView.backgroundColor = settingsRepository.getSecondaryColor()
		popupView.actionLabel.textColor = settingsRepository.getTertiaryColor()
		popupView.iconImageView.tintColor = settingsRepository.getTertiaryColor()
		
		numberLabel.backgroundColor = settingsRepository.getSecondaryColor()
		numberLabel.textColor = settingsRepository.getTertiaryColor()
		
		encountersLabel.backgroundColor = settingsRepository.getSecondaryColor()
		encountersLabel.textColor = settingsRepository.getTertiaryColor()
		
		probabilityLabel.backgroundColor = settingsRepository.getSecondaryColor()
		probabilityLabel.textColor = settingsRepository.getTertiaryColor()
		
		gifSeparatorView.backgroundColor = settingsRepository.getSecondaryColor()
		
		pokeballButton.backgroundColor = settingsRepository.getPrimaryColor()
		
		plusButton.tintColor = settingsRepository.getTertiaryColor()
		minusButton.tintColor = settingsRepository.getTertiaryColor()
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
		numberLabel.font = settingsRepository.getSmallFont()
		probabilityLabel.font = settingsRepository.getSmallFont()
		encountersLabel.font = settingsRepository.getSmallFont()
		popupView.actionLabel.font = settingsRepository.getSmallFont()
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
		if settingsRepository.generation == 3
		{
			let isShinyCharmActive = settingsRepository.isShinyCharmActive
			let isLureInUse = settingsRepository.isLureInUse

			probability = oddsResolver.getLGPEProbability(catchCombo: pokemon.encounters, isShinyCharmActive: isShinyCharmActive, isLureInUse: isLureInUse)
		}
		else
		{
			probability = Double(pokemon.encounters) / Double(settingsRepository.shinyOdds!) * 100
		}
	}

	fileprivate func setProbabilityLabelText()
	{
		let generation = settingsRepository.generation

		oddsResolver.resolveProbability(generation: generation, probability: probability!, probabilityLabel: probabilityLabel, encounters: pokemon.encounters)
	}
	
	fileprivate func setEncountersLabelText()
	{
		let labelTitle: String?

		if settingsRepository.generation == 3
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
		return resolver.resolveButtonAccess(nameList: currentHuntRepository.currentHuntNames, name: pokemon.name)
	}
	
	
	@IBAction func plusPressed(_ sender: Any)
	{
		pokemon.encounters += 1
		resolveEncounterDetails()
		pokemonRepository.savePokemon(pokemon: pokemon)
	}
	
	@IBAction func minusPressed(_ sender: Any)
	{
		pokemon.encounters -= 1
		resolveEncounterDetails()
		pokemonRepository.savePokemon(pokemon: pokemon)
	}
	
	@IBAction func addToHuntPressed(_ sender: Any)
	{
		currentHuntRepository.addToCurrentHunt(pokemon: pokemon)
		
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		
		popupView.actionLabel.text = "\(pokemon.name) was added to current hunt."
		
		popupHandler.centerPopupView(popupView: popupView)
		
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
			destVC.settingsRepository = settingsRepository
		}
		else if setEncountersPressed
		{
			setEncountersPressed = false
			
			let destVC = segue.destination as! SetEncountersModalVC
			
			destVC.pokemon = pokemon
			destVC.pokemonRepository = pokemonRepository
		}
		else
		{
			let destVC = segue.destination as! PokeballModalVC
			
			setPokeballModalProperties(pokeballModalVC: destVC)
		}
	}
	
	fileprivate func setPokeballModalProperties(pokeballModalVC: PokeballModalVC)
	{
		pokeballModalVC.pokemonRepository = pokemonRepository
		pokeballModalVC.pokemon = pokemon
		pokeballModalVC.settingsRepository = settingsRepository
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
		
		pokemonRepository.savePokemon(pokemon: pokemon)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setEncountersLabelText()
	}
}
