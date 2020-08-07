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
	@IBOutlet weak var popupView: PopupView!
	@IBOutlet weak var buttonStrip: ButtonStrip!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var gifSeparatorView: UIView!
	
	var pokemon: Pokemon!
	var hunts: [Hunt]!
	let probabilityService = ProbabilityService()
	let oddsService = OddsService()
	var probability: Double?
	var methodDecrement = 0
	var huntState: HuntState?
	var setEncountersPressed = false
	var isAddingToHunt = false
	var infoPressed = false
	var locationPressed = false
	var incrementPressed = false
	let popupHandler = PopupHandler()
	var pokemonService: PokemonService!
	var fontSettingsService: FontSettingsService!
	var colorService: ColorService!
	var huntService: HuntService!
	var huntStateService: HuntStateService!
	var textResolver = TextResolver()
	
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

		setMethodDecrement()
	
		resolveEncounterDetails()
		
		setNumberLabelText()
		
		setPokeballButtonImage()

		setMethodImage()

		setIncrementImage()
		
		setButtonActions()

		setOddsLabelText()
		
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
	}

	fileprivate func setMethodDecrement()
	{
		if huntState!.huntMethod == .SosChaining || huntState!.huntMethod == .Lure || huntState!.generation == 6
		{
			methodDecrement = 30
		}
		else if huntState!.huntMethod == .ChainFishing
		{
			methodDecrement = 20
		}
		else if huntState!.huntMethod == .Pokeradar
		{
			methodDecrement = 40
		}
		else if huntState!.huntMethod == .DexNav
		{
			methodDecrement = 999
		}
		else if huntState!.generation == 5 && huntState!.huntMethod != .Masuda
		{
			methodDecrement = 500
		}
		else
		{
			methodDecrement = 0
		}
	}

	fileprivate func hidePopupView()
	{
		popupView.isHidden = true
	}
	
	fileprivate func setPokeballButtonImage()
	{
		buttonStrip.pokeballButton.setImage(UIImage(named: pokemon.caughtBall), for: .normal)
	}

	fileprivate func setMethodImage()
	{
		buttonStrip.methodButton.setImage(getMethodImage(), for: .normal)
	}

	fileprivate func getMethodImage() -> UIImage
	{
		switch huntState!.huntMethod
		{
		case .Gen2Breeding:
			return UIImage(named: "gyarados")!
		case .Masuda:
			return UIImage(named: "egg")!
		case .Pokeradar:
			return UIImage(named: "poke-radar")!
		case .FriendSafari:
			return UIImage(named: "heart-mail")!
		case .ChainFishing:
			return UIImage(named: "super-rod")!
		case .DexNav:
			return UIImage(named: "wide-lens")!
		case .SosChaining:
			return UIImage(named: "sos")!
		case .Lure:
			return UIImage(named: "max-lure")!
		default:
			if huntState!.huntMethod == .Encounters && huntState!.isShinyCharmActive
			{
				return UIImage(named: "shiny-charm")!
			}

			return UIImage(systemName: "info.circle.fill")!
		}
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
		
		plusButton.tintColor = colorService.getTertiaryColor()
		minusButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func roundCorners()
	{
		popupView.layer.cornerRadius = CornerRadius.Standard.rawValue
		numberLabel.layer.cornerRadius = CornerRadius.Standard.rawValue
		encountersLabel.layer.cornerRadius = CornerRadius.Standard.rawValue
		probabilityLabel.layer.cornerRadius = CornerRadius.Standard.rawValue
		gifSeparatorView.layer.cornerRadius = CornerRadius.Standard.rawValue
	}
	
	fileprivate func roundDoubleVerticalButtonsViewCorners()
	{
		buttonStrip.layer.cornerRadius = CornerRadius.Standard.rawValue
	}
	
	fileprivate func setFonts()
	{
		numberLabel.font = fontSettingsService.getSmallFont()
		probabilityLabel.font = fontSettingsService.getExtraSmallFont()
		encountersLabel.font = fontSettingsService.getExtraSmallFont()
		popupView.actionLabel.font = fontSettingsService.getSmallFont()
	}
	
	fileprivate func setTitle()
	{
		title = pokemon.name
	}
	
	fileprivate func setGif()
	{
		if let shinyGifAsset = NSDataAsset(name: "\(pokemon.name)")
		{
			let data = shinyGifAsset.data
			gifImageView.image = UIImage.gifImageWithData(data, 300.0)
		}

	}
	
	fileprivate func setButtonActions()
	{
		buttonStrip.updateEncountersButton.addTarget(self, action: #selector(updateEncountersPressed), for: .touchUpInside)
		buttonStrip.incrementButton.addTarget(self, action: #selector(incrementButtonPressed), for: .touchUpInside)
		buttonStrip.methodButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		buttonStrip.pokeballButton.addTarget(self, action: #selector(changeCaughtButtonPressed), for: .touchUpInside)
		buttonStrip.locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
	}
	
	fileprivate func resolveEncounterDetails()
	{
		setProbability()
		setProbabilityLabelText()
		encountersLabel.text = textResolver.getEncountersLabelText(huntState: huntState!, encounters: pokemon.encounters, methodDecrement: methodDecrement)
		setOddsLabelText()
		minusButton.isEnabled = minusButtonIsEnabled()
	}
	
	fileprivate func setProbability()
	{

		var encounters = pokemon.encounters
		huntState!.shinyOdds = oddsService.getShinyOdds(generation: huntState!.generation, isCharmActive: huntState!.isShinyCharmActive, huntMethod: huntState!.huntMethod, encounters: encounters)
		encounters -= methodDecrement
		probability = probabilityService.getProbability(encounters: encounters, shinyOdds: huntState!.shinyOdds)
	}

	fileprivate func setProbabilityLabelText()
	{
		let encounters = pokemon.encounters
		let probabilityLabelText = probabilityService.getProbabilityText(encounters: encounters, shinyOdds: huntState!.shinyOdds, probability: probability!,  huntState: huntState!, methodDecrement: methodDecrement)
		probabilityLabel.text = probabilityLabelText
	}
	
	fileprivate func setNumberLabelText()
	{
		numberLabel.text = " No. \(pokemon.number + 1)"
	}

	fileprivate func setOddsLabelText()
	{
		buttonStrip.oddsLabel.text = "1/\(huntState!.shinyOdds)"
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

	@objc fileprivate func incrementButtonPressed(_ sender: Any)
	{
		incrementPressed = true
		performSegue(withIdentifier: "incrementSegue", sender: self)
	}

	@objc fileprivate func changeCaughtButtonPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "shinyTrackerToModalSegue", sender: self)
	}

	@objc fileprivate func locationButtonPressed(_ sender: Any)
	{
		locationPressed = true
		performSegue(withIdentifier: "locationSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if infoPressed
		{
			infoPressed = false
		}
		else if setEncountersPressed
		{
			setEncountersPressed = false
			let destVC = segue.destination as! SetEncountersModalVC
			destVC.pokemon = pokemon
			destVC.pokemonService = pokemonService
			destVC.huntState = huntState
			destVC.methodDecrement = methodDecrement
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
		else if locationPressed
		{
			locationPressed = false
			let destVC = segue.destination as! LocationVC
			destVC.generation = huntState?.generation
			destVC.pokemon = pokemon
		}
		else if incrementPressed
		{
			incrementPressed = false
			let destVC = segue.destination as! IncrementVC
			destVC.colorService = colorService
			destVC.fontSettingsService = fontSettingsService
			destVC.huntStateService = huntStateService
			destVC.huntState = huntState
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
			
			buttonStrip.pokeballButton.setImage(UIImage(named: pokemon.caughtBall), for: .normal)
		}
	}
	
	@IBAction func saveEncounters(_ unwindSegue: UIStoryboardSegue)
	{
		let sourceVC = unwindSegue.source as! SetEncountersModalVC
		pokemon = sourceVC.pokemon
		pokemonService.save(pokemon: pokemon)
		resolveEncounterDetails()
	}

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue)
	{
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		let source = unwindSegue.source as! HuntPickerModalVC
		let huntName = source.pickedHuntName
		popupView.actionLabel.text = "\(pokemon!.name) was added to \(huntName!)."
		popupHandler.showPopup(popupView: popupView)
	}

	@IBAction func dismissModal(_ unwindSegue: UIStoryboardSegue)
	{
		huntState = huntStateService.get()
		setMethodImage()
		setMethodDecrement()
		setProbability()
		setProbabilityLabelText()
		encountersLabel.text = textResolver.getEncountersLabelText(huntState: huntState!, encounters: pokemon.encounters, methodDecrement: methodDecrement)
		setOddsLabelText()
	}

	@IBAction func confirmIncrement(_ unwindSegue: UIStoryboardSegue)
	{
		setIncrementImage()
	}

	fileprivate func setIncrementImage()
	{
		switch huntState!.increment
		{
		case 0,1:
			buttonStrip.incrementButton.setImage(UIImage(systemName: "1.circle.fill"), for: .normal)
			break
		case 3:
			buttonStrip.incrementButton.setImage(UIImage(systemName: "3.circle.fill"), for: .normal)
			break
		case 4:
			buttonStrip.incrementButton.setImage(UIImage(systemName: "4.circle.fill"), for: .normal)
			break
		case 5:
			buttonStrip.incrementButton.setImage(UIImage(systemName: "5.circle.fill"), for: .normal)
			break
		default:
			buttonStrip.incrementButton.setImage(UIImage(systemName: "6.circle.fill"), for: .normal)
			break
		}
	}
}
