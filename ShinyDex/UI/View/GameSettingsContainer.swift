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
	var huntStateService = HuntStateService()
	var oddsService = OddsService()
	var switchStateService = SwitchStateService()
	var huntState: HuntState?

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


	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		huntState = huntStateService.get()

		generationSeparator.layer.cornerRadius = 5
		genTwoBreedingCell.iconImageView.image = UIImage(named: "gyarados")
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
		sosChainCell.iconImageView.image = UIImage(named: "sos")
		sosChainCell.titleLabel.text = "SOS chaining"
		sosChainCell.descriptionLabel.text = "SOS chaining is only available in generation 7"
		lureCell.iconImageView.image = UIImage(named: "max-lure")
		lureCell.titleLabel.text = "Lure"
		lureCell.descriptionLabel.text = "Lures are only available in Let's Go Pikachu & Eevee"
		lureCell.actionSwitch.addTarget(self, action: #selector(changeIsLureInUse), for: .valueChanged)
		shinyCharmCell.actionSwitch.addTarget(self, action: #selector(changeIsShinyCharmActive), for: .valueChanged)
		masudaCell.actionSwitch.addTarget(self, action: #selector(changeIsMasudaHunting), for: .valueChanged)
		generationSegmentedControl.addTarget(self, action: #selector(changeGenerationPressed), for: .valueChanged)
		setUIColors()
		setFonts()
		setShinyOddsLabelText()
		resolveUIObjectsState()
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

	fileprivate func resolveUIObjectsState()
	{
		generationSegmentedControl.selectedSegmentIndex = huntState!.generation
		shinyCharmCell.actionSwitch.isOn = huntState!.isShinyCharmActive
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)

		lureCell.actionSwitch.isOn = huntState!.isLureInUse
		setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)

		masudaCell.actionSwitch.isOn = huntState!.isMasudaHunting
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)
	}

	fileprivate func setShinyOddsLabelText()
	{
		shinyOddsLabel.text = "Shiny Odds: 1/\(huntState!.shinyOdds)"
	}

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool)
	{
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
	}

	func setUIColors()
	{
		contentView?.backgroundColor = colorService.getSecondaryColor()
		generationSeparator.backgroundColor = colorService.getPrimaryColor()
		generationLabel.textColor = colorService.getTertiaryColor()
		shinyOddsLabel.textColor = colorService.getTertiaryColor()
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		generationLabel.textColor = colorService.getTertiaryColor()
		generationSegmentedControl.backgroundColor = colorService.getSecondaryColor()
		generationSegmentedControl.tintColor = colorService.getPrimaryColor()
	}

	func setCellColors()
	{
		genTwoBreedingCell.setUIColors()
		masudaCell.setUIColors()
		pokeradarCell.setUIColors()
		shinyCharmCell.setUIColors()
		chainFishingCell.setUIColors()
		dexNavCell.setUIColors()
		sosChainCell.setUIColors()
		lureCell.setUIColors()
	}

	func setFonts()
	{
		generationLabel.font = fontSettingsService.getExtraLargeFont()
		shinyOddsLabel.font = fontSettingsService.getMediumFont()
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
	}

	func setCellFonts()
	{
		genTwoBreedingCell.setFonts()
		masudaCell.setFonts()
		pokeradarCell.setFonts()
		shinyCharmCell.setFonts()
		chainFishingCell.setFonts()
		dexNavCell.setFonts()
		sosChainCell.setFonts()
		lureCell.setFonts()
	}

	@objc fileprivate func changeIsLureInUse(_ sender: Any)
	{
		huntState!.isLureInUse = lureCell.actionSwitch.isOn
		setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generationSegmentedControl.selectedSegmentIndex, shinyCharmCell.actionSwitch.isOn, huntState!.isLureInUse, masudaCell.actionSwitch.isOn)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsShinyCharmActive(_ sender: Any)
	{
		huntState?.isShinyCharmActive = shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generationSegmentedControl.selectedSegmentIndex, huntState!.isShinyCharmActive, lureCell.actionSwitch.isOn, masudaCell.actionSwitch.isOn)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsMasudaHunting(_ sender: Any)
	{
		huntState?.isMasudaHunting = masudaCell.actionSwitch.isOn
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generationSegmentedControl.selectedSegmentIndex, shinyCharmCell.actionSwitch.isOn, lureCell.actionSwitch.isOn, huntState!.isMasudaHunting)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeGenerationPressed(_ sender: Any)
	{
		let generation = generationSegmentedControl.selectedSegmentIndex

		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: shinyCharmCell.actionSwitch)
		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: lureCell.actionSwitch)
		switchStateService.resolveMasudaSwitchState(generation: generation, masudaSwitch: masudaCell.actionSwitch)

		huntState!.generation = generation

		huntState!.isShinyCharmActive = shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)

		huntState!.isLureInUse = lureCell.actionSwitch.isOn
		setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: huntState!.isLureInUse)

		huntState!.isMasudaHunting = masudaCell.actionSwitch.isOn
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: huntState!.isMasudaHunting)

		huntState!.shinyOdds = oddsService.getShinyOdds(huntState!.generation, huntState!.isShinyCharmActive, huntState!.isLureInUse, huntState!.isMasudaHunting)

		setShinyOddsLabelText()

		huntStateService.save(huntState!)
	}
}
