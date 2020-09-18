//
//  GameSettingsContainer.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsContainer: UIView
{
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var pokemonService = PokemonService()
	var oddsService = OddsService()
	var switchStateService = SwitchStateService()
	var pokemon: Pokemon!
	var gameSettingsCells: [GameSettingsCell]?
	var delegate: SegueActivated!

	let nibName = "GameSettingsContainer"
    var contentView: UIView?
	@IBOutlet weak var generationLabel: UILabel!
	@IBOutlet weak var generationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmCell: GameSettingsCell!
	@IBOutlet weak var lureCell: GameSettingsCell!
	@IBOutlet weak var masudaCell: GameSettingsCell!
	@IBOutlet weak var pokeradarCell: GameSettingsCell!
	@IBOutlet weak var genTwoBreedingCell: GameSettingsCell!
	@IBOutlet weak var sosChainCell: GameSettingsCell!
	@IBOutlet weak var shinyOddsLabel: UILabel!
	@IBOutlet weak var generationSeparator: UIView!
	@IBOutlet weak var chainFishingCell: GameSettingsCell!
	@IBOutlet weak var dexNavCell: GameSettingsCell!
	@IBOutlet weak var friendSafariCell: GameSettingsCell!
	@IBOutlet weak var explanationSeparator: UIView!
	@IBOutlet weak var useIncrementCell: GameSettingsCell!
	@IBOutlet weak var applyToAllButton: UIButton!
	@IBOutlet weak var explanationLabel: UILabel!


	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		gameSettingsCells = [useIncrementCell,genTwoBreedingCell, masudaCell, pokeradarCell, shinyCharmCell, chainFishingCell, dexNavCell, friendSafariCell, sosChainCell, lureCell]

		explanationSeparator.layer.cornerRadius = CornerRadius.Standard.rawValue
		applyToAllButton.layer.cornerRadius = CornerRadius.Standard.rawValue
		generationSeparator.layer.cornerRadius = CornerRadius.Standard.rawValue
		useIncrementCell.iconImageView.image = UIImage(systemName: "goforward.plus")
		useIncrementCell.titleLabel.text = "Use increment in Hunts"
		useIncrementCell.descriptionLabel.text = "The encounter increment can be changed on an individual Pokémon"
		genTwoBreedingCell.iconImageView.image = UIImage(named: "ditto-large")
		genTwoBreedingCell.titleLabel.text = "Gen 2 breeding"
		genTwoBreedingCell.descriptionLabel.text = "Increased shiny odds from breeding shinies are only available in generation 2"
		masudaCell.iconImageView.image = UIImage(named: "egg")
		masudaCell.titleLabel.text = "Masuda"
		masudaCell.descriptionLabel.text = "The Masuda method is only available from generation 4 and onwards"
		pokeradarCell.iconImageView.image = UIImage(named: "poke-radar")
		pokeradarCell.titleLabel.text = "Pokéradar"
		pokeradarCell.descriptionLabel.text = "The Pokéradar is only available in Diamond, Pearl, Platinum, X and Y (Generation 4 & 6)"
		shinyCharmCell.iconImageView.image = UIImage(named: "shiny-charm")
		shinyCharmCell.titleLabel.text = "Shiny Charm"
		shinyCharmCell.descriptionLabel.text = "The shiny charm is only available from generation 5 and onwards"
		chainFishingCell.iconImageView.image = UIImage(named: "super-rod")
		chainFishingCell.titleLabel.text = "Chain fishing"
		chainFishingCell.descriptionLabel.text = "Chain fishing is only available in generation 6 (X, Y, Omega Ruby and Alpha Sapphire)"
		dexNavCell.iconImageView.image = UIImage(named: "wide-lens")
		dexNavCell.titleLabel.text = "DexNav"
		dexNavCell.descriptionLabel.text = "The DexNav is only available in Omega Ruby & Alpha Sapphire (Generation 6)"
		friendSafariCell.iconImageView.image = UIImage(named: "heart-mail")
		friendSafariCell.titleLabel.text = "Friend Safari"
		friendSafariCell.descriptionLabel.text = "The Friend Safari is only available in X & Y (Generation 6)"
		sosChainCell.iconImageView.image = UIImage(named: "sos")
		sosChainCell.titleLabel.text = "SOS chaining"
		sosChainCell.descriptionLabel.text = "SOS chaining is only available in generation 7"
		lureCell.iconImageView.image = UIImage(named: "max-lure")
		lureCell.titleLabel.text = "Lure"
		lureCell.descriptionLabel.text = "Lures are only available in Let's Go Pikachu & Eevee"
		lureCell.actionSwitch.addTarget(self, action: #selector(changeIsLureInUse), for: .valueChanged)
		shinyCharmCell.actionSwitch.addTarget(self, action: #selector(changeIsShinyCharmActive), for: .valueChanged)
		masudaCell.actionSwitch.addTarget(self, action: #selector(changeIsMasudaHunting), for: .valueChanged)
		genTwoBreedingCell.actionSwitch.addTarget(self, action: #selector(changeIsGen2Breeding), for: .valueChanged)
		friendSafariCell.actionSwitch.addTarget(self, action: #selector(changeIsFriendSafariHunting), for: .valueChanged)
		chainFishingCell.actionSwitch.addTarget(self, action: #selector(changeIsChainFishing(_:)), for: .valueChanged)
		sosChainCell.actionSwitch.addTarget(self, action: #selector(changeIsSosChaining), for: .valueChanged)
		pokeradarCell.actionSwitch.addTarget(self, action: #selector(changeIsPokeradarHunting), for: .valueChanged)
		dexNavCell.actionSwitch.addTarget(self, action: #selector(changeIsDexNavHunting), for: .valueChanged)
		generationSegmentedControl.addTarget(self, action: #selector(changeGenerationPressed), for: .valueChanged)
		useIncrementCell.actionSwitch.addTarget(self, action: #selector(changeUseIncrementInHunts), for: .valueChanged)
		setUIColors()
		setFonts()
    }

    override init(frame: CGRect)
	{
        super.init(frame: frame)
        commonInit()
    }

    func commonInit()
	{
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView?
	{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

	func resolveUIObjectsState()
	{
		generationSegmentedControl.selectedSegmentIndex = pokemon!.generation

		genTwoBreedingCell.actionSwitch.isOn = pokemon!.huntMethod == .Gen2Breeding
		masudaCell.actionSwitch.isOn = pokemon!.huntMethod == .Masuda
		shinyCharmCell.actionSwitch.isOn = pokemon!.isShinyCharmActive
		friendSafariCell.actionSwitch.isOn = pokemon!.huntMethod == .FriendSafari
		chainFishingCell.actionSwitch.isOn = pokemon!.huntMethod == .ChainFishing
		sosChainCell.actionSwitch.isOn = pokemon!.huntMethod == .SosChaining
		dexNavCell.actionSwitch.isOn = pokemon!.huntMethod == .DexNav
		lureCell.actionSwitch.isOn = pokemon!.huntMethod == .Lure
		useIncrementCell.actionSwitch.isOn = pokemon!.useIncrementInHunts

		setAllImageViewAlphas()
		resolveSwitchStates()
	}

	func setShinyOddsLabelText()
	{
		shinyOddsLabel.text = "Shiny Odds: 1/\(pokemon!.shinyOdds)"
	}

	func setExplanationLabelText()
	{
		explanationLabel.text = pokemon.name == "Placeholder"
		? "From here you can apply game settings to all Pokémon. Editing the settings will not be applied to any Pokémon, unless the button below is pressed."
		: "Editing the game settings from here will immediately apply it to \(pokemon.name).\nTo apply the selected settings to all Pokémon, press the button below."
	}

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool)
	{
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
	}

	func setUIColors()
	{
		contentView?.backgroundColor = colorService.getPrimaryColor()
		explanationLabel.textColor = colorService.getTertiaryColor()
		applyToAllButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		applyToAllButton.backgroundColor = colorService.getSecondaryColor()
		explanationSeparator.backgroundColor = colorService.getSecondaryColor()
		generationSeparator.backgroundColor = colorService.getSecondaryColor()
		generationLabel.textColor = colorService.getTertiaryColor()
		shinyOddsLabel.textColor = colorService.getTertiaryColor()
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		generationLabel.textColor = colorService.getTertiaryColor()
		generationSegmentedControl.backgroundColor = colorService.getPrimaryColor()
		generationSegmentedControl.tintColor = colorService.getSecondaryColor()
		useIncrementCell.iconImageView.tintColor = colorService.getTertiaryColor()
	}

	func setCellColors()
	{
		useIncrementCell.iconImageView.tintColor = colorService.getTertiaryColor()
		for cell in gameSettingsCells!
		{
			cell.setUIColors()
		}
	}

	func setFonts()
	{
		explanationLabel.font = fontSettingsService.getSmallFont()
		applyToAllButton.titleLabel?.font = fontSettingsService.getMediumFont()
		generationLabel.font = fontSettingsService.getExtraLargeFont()
		shinyOddsLabel.font = fontSettingsService.getMediumFont()
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
		useIncrementCell.titleLabel.font = fontSettingsService.getExtraSmallFont()
	}

	func setCellFonts()
	{
		for cell in gameSettingsCells!
		{
			cell.setFonts()
		}
		useIncrementCell.titleLabel.font = fontSettingsService.getExtraSmallFont()
	}

	@objc fileprivate func changeIsGen2Breeding(_ sender: Any)
	{
		pokemon!.huntMethod = genTwoBreedingCell.actionSwitch.isOn ? .Gen2Breeding : .Encounters
		setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Gen2Breeding)
		pokemon?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: pokemon!.huntMethod)
		setShinyOddsLabelText()
		saveIfReal()
	}

	@objc fileprivate func changeIsFriendSafariHunting()
	{
		pokemon!.huntMethod = friendSafariCell.actionSwitch.isOn ? .FriendSafari : .Encounters
		setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .FriendSafari)
		turnSwitchesOff(enabledCell: friendSafariCell, huntMethod: pokemon!.huntMethod)
	}

	@objc fileprivate func changeIsLureInUse(_ sender: Any)
	{
		pokemon!.huntMethod = lureCell.actionSwitch.isOn ? .Lure : .Encounters
		setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Lure)
		pokemon?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: pokemon!.huntMethod)
		setShinyOddsLabelText()
		saveIfReal()
	}

	@objc fileprivate func changeIsShinyCharmActive(_ sender: Any)
	{
		pokemon?.isShinyCharmActive = shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
		pokemon?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: pokemon!.isShinyCharmActive, huntMethod: pokemon!.huntMethod)
		setShinyOddsLabelText()
		saveIfReal()
	}

	@objc fileprivate func changeIsMasudaHunting(_ sender: Any)
	{
		pokemon?.huntMethod = masudaCell.actionSwitch.isOn ? .Masuda : .Encounters
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Masuda)
		turnSwitchesOff(enabledCell: masudaCell, huntMethod: pokemon!.huntMethod)
		saveIfReal()
	}

	@objc fileprivate func changeIsPokeradarHunting(_ sender: Any)
	{
		pokemon?.huntMethod = pokeradarCell.actionSwitch.isOn ? .Pokeradar : .Encounters
		setImageViewAlpha(imageView: pokeradarCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Pokeradar)
		turnSwitchesOff(enabledCell: pokeradarCell, huntMethod: pokemon!.huntMethod)
		saveIfReal()
	}

	@objc fileprivate func changeIsChainFishing(_ sender: Any)
	{
		pokemon?.huntMethod = chainFishingCell.actionSwitch.isOn ? .ChainFishing : .Encounters
		setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .ChainFishing)
		turnSwitchesOff(enabledCell: chainFishingCell, huntMethod: pokemon!.huntMethod)
		saveIfReal()
	}

	@objc fileprivate func changeIsDexNavHunting(_ sender: Any)
	{
		pokemon?.huntMethod = dexNavCell.actionSwitch.isOn ? .DexNav : .Encounters
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .DexNav)
		turnSwitchesOff(enabledCell: dexNavCell, huntMethod: pokemon!.huntMethod)
		saveIfReal()
	}

	@objc fileprivate func changeIsSosChaining(_ sender: Any)
	{
		pokemon?.huntMethod = sosChainCell.actionSwitch.isOn ? .SosChaining : .Encounters
		setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .SosChaining)
		turnSwitchesOff(enabledCell: sosChainCell, huntMethod: pokemon!.huntMethod)
		saveIfReal()
	}

	@objc fileprivate func changeUseIncrementInHunts(_ sender: Any)
	{
		pokemon?.useIncrementInHunts = useIncrementCell.actionSwitch.isOn
		setImageViewAlpha(imageView: useIncrementCell.iconImageView, isSwitchOn: pokemon!.useIncrementInHunts)
		saveIfReal()
	}

	@objc fileprivate func changeGenerationPressed(_ sender: Any)
	{
		pokemon!.generation = generationSegmentedControl.selectedSegmentIndex

		if pokemon?.huntMethod != .Masuda || pokemon?.generation == 0 || pokemon?.generation == 6
		{
			pokemon?.huntMethod = .Encounters
		}

		resolveSwitchStates()

		setAllImageViewAlphas()

		pokemon!.shinyOdds = oddsService.getShinyOdds(generation: pokemon!.generation, isCharmActive: pokemon!.isShinyCharmActive, huntMethod: pokemon!.huntMethod)

		setShinyOddsLabelText()

		saveIfReal()
	}

	fileprivate func saveIfReal()
	{
		if pokemon.name != "Placeholder"
		{
			pokemonService.save(pokemon: pokemon)
		}
	}

	fileprivate func setAllImageViewAlphas()
	{
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
		if pokemon?.generation == 0
		{
			setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Gen2Breeding)
		}
		else
		{
			setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: false)
		}
		if pokemon?.generation == 6
		{
			setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Lure)
		}
		else
		{
			setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: false)
		}
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Masuda)
		setImageViewAlpha(imageView: pokeradarCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .Pokeradar)
		setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .ChainFishing)
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .DexNav)
		setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .FriendSafari)
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .DexNav)
		setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: pokemon!.huntMethod == .SosChaining)
		setImageViewAlpha(imageView: useIncrementCell.iconImageView, isSwitchOn: pokemon!.useIncrementInHunts)
	}

	fileprivate func turnSwitchesOff(enabledCell: GameSettingsCell, huntMethod: HuntMethod)
	{
		gameSettingsCells!.removeAll{$0 == enabledCell || $0 == shinyCharmCell || $0 == useIncrementCell}
		for cell in gameSettingsCells!
		{
			setImageViewAlpha(imageView: cell.iconImageView, isSwitchOn: false)
			cell.actionSwitch.isOn = false
		}
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
		setImageViewAlpha(imageView: enabledCell.iconImageView, isSwitchOn: enabledCell.actionSwitch.isOn)
		gameSettingsCells!.append(enabledCell)
		gameSettingsCells!.append(shinyCharmCell)
		pokemon?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: pokemon!.huntMethod)
			setShinyOddsLabelText()
		saveIfReal()
	}

	fileprivate func resolveSwitchStates()
	{
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon!, shinyCharmSwitch: shinyCharmCell.actionSwitch)
		switchStateService.resolveLureSwitchState(pokemon: pokemon!, lureSwitch: lureCell.actionSwitch)
		switchStateService.resolveMasudaSwitchState(pokemon: pokemon!, masudaSwitch: masudaCell.actionSwitch)
		switchStateService.resolveGen2BreddingSwitchState(pokemon: pokemon!, gen2BreedingSwitch: genTwoBreedingCell.actionSwitch)
		switchStateService.resolveFriendSafariSwitchState(pokemon: pokemon!, friendSafariSwitch: friendSafariCell.actionSwitch)
		switchStateService.resolveSosChainingSwitchState(pokemon: pokemon!, sosChainingSwitch: sosChainCell.actionSwitch)
		switchStateService.resolveChainFishingSwitchState(pokemon: pokemon!, chainFishingSwitch: chainFishingCell.actionSwitch)
		switchStateService.resolvePokeradarSwitchState(pokemon: pokemon!, pokeradarSwitch: pokeradarCell.actionSwitch)
		switchStateService.resolveDexNavSwitchState(pokemon: pokemon!, dexNavSwitch: dexNavCell.actionSwitch)
	}

	@IBAction func applyToAllPressed(_ sender: Any)
	{
		delegate.segueActivated()
	}
}
