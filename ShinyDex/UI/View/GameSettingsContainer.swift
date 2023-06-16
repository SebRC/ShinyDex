import UIKit

class GameSettingsContainer: UIView {
	var pokemonService = PokemonService()
	var oddsService = OddsService()
	var switchStateService = SwitchStateService()
	var pokemon: Pokemon!
	var gameSettingsCells: [GameSettingsCell]?
	var delegate: SegueActivated!

	let nibName = "GameSettingsContainer"
    var contentView: UIView?
	@IBOutlet weak var gameLabel: UILabel!
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
	@IBOutlet weak var useIncrementCell: GameSettingsCell!
	@IBOutlet weak var applyToAllButton: UIButton!
	@IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var gameTitle: UILabel!
    

	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)

		gameSettingsCells = [useIncrementCell,genTwoBreedingCell, masudaCell, pokeradarCell, shinyCharmCell, chainFishingCell, dexNavCell, friendSafariCell, sosChainCell, lureCell]

		applyToAllButton.layer.cornerRadius = CornerRadius.standard
        gameButton.layer.cornerRadius = CornerRadius.standard
		generationSeparator.layer.cornerRadius = CornerRadius.standard
		useIncrementCell.iconImageView.image = UIImage(systemName: "goforward.plus")
		useIncrementCell.titleLabel.text = "Increment in hunts"
		useIncrementCell.descriptionLabel.text = "Enable the encounter increment to be active when hunting from the Hunts menu."
		genTwoBreedingCell.actionSwitch.tag = 0
		genTwoBreedingCell.iconImageView.image = UIImage(named: HuntMethod.Gen2Breeding.rawValue)
		genTwoBreedingCell.titleLabel.text = "Gen 2 breeding"
		genTwoBreedingCell.descriptionLabel.text = "Increased shiny odds from breeding shinies are only available in generation 2."
		masudaCell.actionSwitch.tag = 1
		masudaCell.iconImageView.image = UIImage(named: HuntMethod.Masuda.rawValue)
		masudaCell.titleLabel.text = "Masuda"
		masudaCell.descriptionLabel.text = "The Masuda method is only available from generation 4 and onwards."
		pokeradarCell.actionSwitch.tag = 2
		pokeradarCell.iconImageView.image = UIImage(named: HuntMethod.Pokeradar.rawValue)
		pokeradarCell.titleLabel.text = "Pokéradar"
		pokeradarCell.descriptionLabel.text = "The Pokéradar is only available in the generation 4 games Diamond, Pearl and Platinum and the genration 6 games X and Y."
		shinyCharmCell.actionSwitch.tag = 3
		shinyCharmCell.iconImageView.image = UIImage(named: "Charm")
		shinyCharmCell.titleLabel.text = "Shiny Charm"
		shinyCharmCell.descriptionLabel.text = "The shiny charm is only available from generation 5 and onwards."
		chainFishingCell.actionSwitch.tag = 4
		chainFishingCell.iconImageView.image = UIImage(named: HuntMethod.ChainFishing.rawValue)
		chainFishingCell.titleLabel.text = "Chain fishing"
		chainFishingCell.descriptionLabel.text = "Chain fishing is only available in generation 6."
		dexNavCell.actionSwitch.tag = 5
		dexNavCell.iconImageView.image = UIImage(named: HuntMethod.DexNav.rawValue)
		dexNavCell.titleLabel.text = "DexNav"
		dexNavCell.descriptionLabel.text = "The DexNav is only available in the generation 6 games Omega Ruby & Alpha Sapphire."
		friendSafariCell.actionSwitch.tag = 6
		friendSafariCell.iconImageView.image = UIImage(named: HuntMethod.FriendSafari.rawValue)
		friendSafariCell.titleLabel.text = "Friend Safari"
		friendSafariCell.descriptionLabel.text = "The Friend Safari is only available in the genration 6 games, X and Y."
		sosChainCell.actionSwitch.tag = 7
		sosChainCell.iconImageView.image = UIImage(named: HuntMethod.SosChaining.rawValue)
		sosChainCell.titleLabel.text = "SOS chaining"
		sosChainCell.descriptionLabel.text = "SOS chaining is only available in generation 7."
		lureCell.actionSwitch.tag = 8
		lureCell.iconImageView.image = UIImage(named: HuntMethod.Lure.rawValue)
		lureCell.titleLabel.text = "Lure"
		lureCell.descriptionLabel.text = "Lures are only available in Let's Go Pikachu & Eevee."
		lureCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		shinyCharmCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		masudaCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		genTwoBreedingCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		friendSafariCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		chainFishingCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		sosChainCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		pokeradarCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		dexNavCell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
		useIncrementCell.actionSwitch.addTarget(self, action: #selector(changeUseIncrementInHunts), for: .valueChanged)
		setUIColors()
        gameButton.setTitle("", for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }

	func resolveUIObjectsState() {
		genTwoBreedingCell.actionSwitch.isOn = pokemon.huntMethod == .Gen2Breeding
		masudaCell.actionSwitch.isOn = pokemon.huntMethod == .Masuda
		shinyCharmCell.actionSwitch.isOn = pokemon.isShinyCharmActive
		friendSafariCell.actionSwitch.isOn = pokemon.huntMethod == .FriendSafari
		chainFishingCell.actionSwitch.isOn = pokemon.huntMethod == .ChainFishing
		sosChainCell.actionSwitch.isOn = pokemon.huntMethod == .SosChaining
		dexNavCell.actionSwitch.isOn = pokemon.huntMethod == .DexNav
		lureCell.actionSwitch.isOn = pokemon.huntMethod == .Lure
		useIncrementCell.actionSwitch.isOn = pokemon.useIncrementInHunts

		setAllImageViewAlphas()
		resolveSwitchStates()
	}

	func setShinyOddsLabelText() {
		pokemon!.shinyOdds = oddsService.getShinyOdds(pokemon: pokemon)
		shinyOddsLabel.text = "Shiny Odds: 1/\(pokemon!.shinyOdds)"
	}

	func setExplanationLabelText() {
		explanationLabel.text = pokemon.name == "Placeholder"
		? "From here you can apply game settings to all Pokémon. Editing the settings will not be applied to any Pokémon, unless the button below is pressed."
		: "Editing the game settings from here will immediately apply them to \(pokemon.name).\nTo apply the selected settings to all Pokémon, press the button below."
	}
    
    func updateUI(updatedPokemon: Pokemon, coverPokemon: String) {
        pokemon = updatedPokemon
        gameButton.setImage(UIImage(named: coverPokemon), for: .normal)
        gameTitle.text = pokemon.game.rawValue
        resolveUIObjectsState()
        setShinyOddsLabelText()
    }

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool) {
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
	}

	func setUIColors() {
        contentView?.backgroundColor = Color.Grey800
        explanationLabel.textColor = Color.Grey200
		applyToAllButton.setTitleColor(Color.Grey200, for: .normal)
		applyToAllButton.backgroundColor = Color.Grey900
		generationSeparator.backgroundColor = Color.Grey900
		shinyOddsLabel.textColor = Color.Grey200
		gameLabel.textColor = Color.Grey200
        gameTitle.textColor = Color.Grey200
        gameButton.backgroundColor = Color.Grey900
		useIncrementCell.iconImageView.tintColor = Color.Grey200
	}

	func setCellColors() {
		useIncrementCell.iconImageView.tintColor = Color.Grey200
		for cell in gameSettingsCells! {
			cell.setUIColors()
		}
	}

	@objc fileprivate func switchPressed(_ sender: UISwitch) {
		let tag = sender.tag
		var selectedHuntMethod = HuntMethod.Encounters
		var icon = UIImageView()
		var cell = GameSettingsCell()
		var callTurnSwitchesOff = true

		if (tag == 0) {
			selectedHuntMethod = .Gen2Breeding
			icon = genTwoBreedingCell.iconImageView
			cell = genTwoBreedingCell
			callTurnSwitchesOff = false
		}
		else if (tag == 1) {
			selectedHuntMethod = .Masuda
			icon = masudaCell.iconImageView
			cell = masudaCell
		}
		else if (tag == 2) {
			selectedHuntMethod = .Pokeradar
			icon = pokeradarCell.iconImageView
			cell = pokeradarCell
		}
		else if (tag == 3) {
			selectedHuntMethod = pokemon!.huntMethod
			pokemon!.isShinyCharmActive = sender.isOn
			setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
			cell = shinyCharmCell
			callTurnSwitchesOff = false
		}
		else if (tag == 4) {
			selectedHuntMethod = .ChainFishing
			icon = chainFishingCell.iconImageView
			cell = chainFishingCell
		}
		else if (tag == 5) {
			selectedHuntMethod = .DexNav
			icon = dexNavCell.iconImageView
			cell = dexNavCell
		}
		else if (tag == 6) {
			selectedHuntMethod = .FriendSafari
			icon = friendSafariCell.iconImageView
			cell = friendSafariCell
		}
		else if (tag == 7) {
			selectedHuntMethod = .SosChaining
			icon = sosChainCell.iconImageView
			cell = sosChainCell
		}
		else if (tag == 8) {
			selectedHuntMethod = .Lure
			icon = lureCell.iconImageView
			cell = lureCell
			callTurnSwitchesOff = false
		}
		let activeHuntMethod = sender.isOn || sender.tag == 3 ? selectedHuntMethod : .Encounters
		pokemon!.huntMethod = activeHuntMethod
		setImageViewAlpha(imageView: icon, isSwitchOn: pokemon!.huntMethod == selectedHuntMethod)
		if (callTurnSwitchesOff) {
			turnSwitchesOff(enabledCell: cell, huntMethod: pokemon!.huntMethod)
		}
		setShinyOddsLabelText()
		saveIfReal()
	}

	@objc fileprivate func changeUseIncrementInHunts(_ sender: Any) {
		pokemon?.useIncrementInHunts = useIncrementCell.actionSwitch.isOn
		setImageViewAlpha(imageView: useIncrementCell.iconImageView, isSwitchOn: pokemon!.useIncrementInHunts)
		saveIfReal()
	}

	fileprivate func saveIfReal() {
		if (pokemon.name != "Placeholder") {
			pokemonService.save(pokemon: pokemon)
		}
	}

	fileprivate func setAllImageViewAlphas() {
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
        setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: pokemon.huntMethod == .Gen2Breeding)
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: pokemon.huntMethod == .Masuda)
		setImageViewAlpha(imageView: pokeradarCell.iconImageView, isSwitchOn: pokemon.huntMethod == .Pokeradar)
		setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: pokemon.huntMethod == .ChainFishing)
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: pokemon.huntMethod == .DexNav)
		setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: pokemon.huntMethod == .FriendSafari)
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: pokemon.huntMethod == .DexNav)
		setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: pokemon.huntMethod == .SosChaining)
        setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: pokemon.huntMethod == .Lure)
		setImageViewAlpha(imageView: useIncrementCell.iconImageView, isSwitchOn: pokemon.useIncrementInHunts)
	}

	fileprivate func turnSwitchesOff(enabledCell: GameSettingsCell, huntMethod: HuntMethod) {
		gameSettingsCells!.removeAll{$0 == enabledCell || $0 == shinyCharmCell || $0 == useIncrementCell}
		for cell in gameSettingsCells! {
			setImageViewAlpha(imageView: cell.iconImageView, isSwitchOn: false)
			cell.actionSwitch.isOn = false
		}
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: pokemon!.isShinyCharmActive)
		setImageViewAlpha(imageView: enabledCell.iconImageView, isSwitchOn: enabledCell.actionSwitch.isOn)
		gameSettingsCells!.append(enabledCell)
		gameSettingsCells!.append(shinyCharmCell)
		gameSettingsCells!.append(useIncrementCell)
		setShinyOddsLabelText()
		saveIfReal()
	}

	fileprivate func resolveSwitchStates() {
		switchStateService.resolveShinyCharmSwitchState(pokemon: pokemon, shinyCharmSwitch: shinyCharmCell.actionSwitch)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: lureCell.actionSwitch, huntMethod: .Lure)
		switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: masudaCell.actionSwitch, huntMethod: .Masuda)
		switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: genTwoBreedingCell.actionSwitch, huntMethod: .Gen2Breeding)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: friendSafariCell.actionSwitch, huntMethod: .FriendSafari)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: sosChainCell.actionSwitch, huntMethod: .SosChaining)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: chainFishingCell.actionSwitch, huntMethod: .ChainFishing)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: pokeradarCell.actionSwitch, huntMethod: .Pokeradar)
        switchStateService.resolveHuntMethodSwitchState(pokemon: pokemon, huntMethodSwitch: dexNavCell.actionSwitch, huntMethod: .DexNav)
	}

	@IBAction func applyToAllPressed(_ sender: Any) {
		delegate.segueActivated()
	}
}
