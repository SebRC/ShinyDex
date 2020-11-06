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
	@IBOutlet weak var percentageLabel: UILabel!
	@IBOutlet weak var addToHuntButton: UIBarButtonItem!
	@IBOutlet weak var buttonStrip: ButtonStrip!
	@IBOutlet weak var gifSeparatorView: UIView!
	
	var pokemon: Pokemon!
	var hunts = [Hunt]()
	let percentageService = PercentageService()
	let oddsService = OddsService()
	var percentage: Double?
	var methodDecrement = 0
	let popupHandler = PopupHandler()
	var pokemonService = PokemonService()
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var huntService = HuntService()
	var textResolver = TextResolver()
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		hunts = huntService.getAll()
		setUIColors()
		roundCorners()
		setFonts()
		setTitle()
		setGif()
		setMethodDecrement()
		resolveEncounterDetails()
		setPokeballButtonImage()
		setMethodImage()
		setIncrementImage()
		setButtonActions()
		setOddsLabelText()
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
	}

	fileprivate func setMethodDecrement()
	{
		if pokemon!.huntMethod == .SosChaining || pokemon!.huntMethod == .Lure || pokemon!.generation == 0
		{
			methodDecrement = 30
		}
		else if pokemon!.huntMethod == .ChainFishing
		{
			methodDecrement = 20
		}
		else if pokemon!.huntMethod == .Pokeradar
		{
			methodDecrement = 40
		}
		else if pokemon!.huntMethod == .DexNav
		{
			methodDecrement = 999
		}
		else
		{
			methodDecrement = 0
		}
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
		let huntMethod = pokemon!.huntMethod
		let canBeCombinedWithCharm = huntMethod != .Gen2Breeding && huntMethod != .Pokeradar
		if pokemon!.isShinyCharmActive && canBeCombinedWithCharm
		{
			return UIImage(named: "\(huntMethod.rawValue) + Charm")!
		}
		else
		{
			return huntMethod != .Encounters
			? UIImage(named: huntMethod.rawValue)!
			: UIImage(systemName: "info.circle.fill")!
		}
	}
	
	fileprivate func setUIColors()
	{
		view.backgroundColor = colorService.getPrimaryColor()
		
		encountersLabel.backgroundColor = colorService.getSecondaryColor()
		encountersLabel.textColor = colorService.getTertiaryColor()
		
		percentageLabel.backgroundColor = colorService.getSecondaryColor()
		percentageLabel.textColor = colorService.getTertiaryColor()
		
		gifSeparatorView.backgroundColor = colorService.getSecondaryColor()
		
		plusButton.tintColor = colorService.getTertiaryColor()
		minusButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func roundCorners()
	{
		encountersLabel.layer.cornerRadius = CornerRadius.Standard.rawValue
		percentageLabel.layer.cornerRadius = CornerRadius.Standard.rawValue
		gifSeparatorView.layer.cornerRadius = CornerRadius.Standard.rawValue
	}
	
	fileprivate func setFonts()
	{
		encountersLabel.font = fontSettingsService.getSmallFont()
		percentageLabel.font = fontSettingsService.getExtraSmallFont()
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
			gifImageView.animate(withGIFData: data)
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
		setPercentage()
		setPercentageLabelText()
		encountersLabel.text = textResolver.getEncountersLabelText(pokemon: pokemon!, encounters: pokemon.encounters, methodDecrement: methodDecrement)
		encountersLabel.font = encountersLabel.text!.contains("999 +")
			? fontSettingsService.getExtraSmallFont()
			: fontSettingsService.getSmallFont()
		setOddsLabelText()
		minusButton.isEnabled = minusButtonIsEnabled()
	}
	
	fileprivate func setPercentage()
	{
		var encounters = pokemon.encounters
		pokemon!.shinyOdds = oddsService.getShinyOdds(generation: pokemon!.generation, isCharmActive: pokemon!.isShinyCharmActive, huntMethod: pokemon!.huntMethod, encounters: encounters)
		encounters -= methodDecrement
		percentage = percentageService.getPercentage(encounters: encounters, shinyOdds: pokemon!.shinyOdds)
	}

	fileprivate func setPercentageLabelText()
	{
		let encounters = pokemon.encounters
		let percentageLabelText = percentageService.getPercentageText(encounters: encounters, shinyOdds: pokemon!.shinyOdds, percentage: percentage!,  pokemon: pokemon!, methodDecrement: methodDecrement)
		percentageLabel.text = percentageLabelText
		percentageLabel.font = percentageLabel.text!.contains("Reach")
		? fontSettingsService.getXxSmallFont()
		: fontSettingsService.getExtraSmallFont()
	}

	fileprivate func setOddsLabelText()
	{
		buttonStrip.oddsLabel.text = "1/\(pokemon!.shinyOdds)"
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
		pokemon.encounters += pokemon!.increment
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
			popupHandler.showPopup(text: "\(pokemon!.name) was added to New Hunt.")
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else if hunts.count == 1
		{
			huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: pokemon!)
			popupHandler.showPopup(text: "\(pokemon!.name) was added to \(hunts[0].name).")
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else
		{
			performSegue(withIdentifier: "shinyTrackerToHuntPickerSegue", sender: self)
		}
	}

	@objc fileprivate func infoButtonPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "infoPopupSegue", sender: self)
	}

	@objc fileprivate func updateEncountersPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "setEncountersSegue", sender: self)
	}

	@objc fileprivate func incrementButtonPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "incrementSegue", sender: self)
	}

	@objc fileprivate func changeCaughtButtonPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "shinyTrackerToModalSegue", sender: self)
	}

	@objc fileprivate func locationButtonPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "locationSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let identifier = segue.identifier
		if identifier == "infoPopupSegue"
		{
			let destVC = segue.destination as! GameSettingsModalVC
			destVC.pokemon = pokemon
		}
		else if identifier == "setEncountersSegue"
		{
			let destVC = segue.destination as! SetEncountersModalVC
			destVC.pokemon = pokemon
			destVC.methodDecrement = methodDecrement
		}
		else if identifier == "shinyTrackerToHuntPickerSegue"
		{
			let destVC = segue.destination as! HuntPickerModalVC
			destVC.pokemon = pokemon
		}
		else if identifier == "locationSegue"
		{
			let destVC = segue.destination as! LocationVC
			destVC.generation = pokemon!.generation
			destVC.pokemon = pokemon
		}
		else if identifier == "incrementSegue"
		{
			let destVC = segue.destination as! IncrementVC
			destVC.pokemon = pokemon
		}
		else
		{
			let destVC = segue.destination as! PokeballModalVC
			destVC.pokemon = pokemon
		}
	}
	
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
		popupHandler.showPopup(text: "\(pokemon!.name) was added to \(huntName!).")
	}

	@IBAction func dismissModal(_ unwindSegue: UIStoryboardSegue)
	{
		setMethodImage()
		setMethodDecrement()
		resolveEncounterDetails()
		setOddsLabelText()
	}

	@IBAction func confirmIncrement(_ unwindSegue: UIStoryboardSegue)
	{
		setIncrementImage()
	}

	fileprivate func setIncrementImage()
	{
		buttonStrip.incrementButton.setImage(UIImage(systemName: "\(pokemon!.increment).circle.fill"), for: .normal)
	}
}
