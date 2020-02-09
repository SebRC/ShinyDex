//
//  InfoPopupView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class InfoPopupView: UIView
{
	let nibName = "InfoPopupView"
    var contentView:UIView?
	
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var spriteImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var shinyOddsLabel: UILabel!
	@IBOutlet weak var probabilityLabel: UILabel!
	@IBOutlet weak var generationLabel: UILabel!
	@IBOutlet weak var generationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmLabel: UILabel!
	@IBOutlet weak var shinyCharmSwitch: UISwitch!
	@IBOutlet weak var pokeballImageView: UIImageView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	
	var oddsResolver = OddsResolver()
	var settingsRepo: SettingsRepository?
	var probability: Double?
	var encounters: Int?
	
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		
		assignSettingsRepository()
		
		setColors()
		
		setFonts()
		
		roundCorners()
		
		setGenerationSegmentedControlSelectedIndex()
		
		setShinyCharmActiveState()
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
	
	fileprivate func assignSettingsRepository()
	{
		if settingsRepo == nil
		{
			settingsRepo = SettingsRepository.settingsRepoSingleton
		}
	}
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = settingsRepo?.getMainColor()

		spriteImageView.backgroundColor = settingsRepo?.getSecondaryColor()
		pokeballImageView.backgroundColor = settingsRepo?.getSecondaryColor()
		
		infoLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		nameLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		numberLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		encountersLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		shinyOddsLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		probabilityLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		shinyCharmLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		generationLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		
		generationSegmentedControl.backgroundColor = settingsRepo?.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepo?.getMainColor()
		
		cancelButton.backgroundColor = settingsRepo?.getSecondaryColor()
		saveButton.backgroundColor = settingsRepo?.getSecondaryColor()
		
		buttonSeparator.backgroundColor = settingsRepo?.getMainColor()
		
		shinyCharmSwitch.thumbTintColor = settingsRepo?.getMainColor()
		shinyCharmSwitch.onTintColor = settingsRepo?.getSecondaryColor()
	}
	
	fileprivate func setFonts()
	{
		infoLabel.font = settingsRepo?.getXxLargeFont()
		nameLabel.font = settingsRepo?.getExtraSmallFont()
		numberLabel.font = settingsRepo?.getExtraSmallFont()
		encountersLabel.font = settingsRepo?.getExtraSmallFont()
		shinyOddsLabel.font = settingsRepo?.getExtraSmallFont()
		probabilityLabel.font = settingsRepo?.getExtraSmallFont()
		shinyCharmLabel.font = settingsRepo?.getExtraSmallFont()
		generationLabel.font = settingsRepo?.getExtraSmallFont()
		
		generationSegmentedControl.setTitleTextAttributes(settingsRepo!.getFontAsNSAttibutedStringKey(fontSize: settingsRepo!.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		cancelButton.titleLabel!.font = settingsRepo?.getExtraSmallFont()
		saveButton.titleLabel!.font = settingsRepo?.getExtraSmallFont()
	}
	
	fileprivate func roundCorners()
	{
		spriteImageView.layer.cornerRadius = 10
		nameLabel.layer.cornerRadius = 10
		numberLabel.layer.cornerRadius = 10
		encountersLabel.layer.cornerRadius = 10
		generationLabel.layer.cornerRadius = 10
		shinyOddsLabel.layer.cornerRadius = 10
		probabilityLabel.layer.cornerRadius = 10
		shinyCharmLabel.layer.cornerRadius = 10
		pokeballImageView.layer.cornerRadius = 10
		buttonSeparator.layer.cornerRadius = 5
	}
	
	fileprivate func setGenerationSegmentedControlSelectedIndex()
	{
		generationSegmentedControl.selectedSegmentIndex = settingsRepo!.generation
	}
	
	fileprivate func setShinyCharmActiveState()
	{
		shinyCharmSwitch.isOn = settingsRepo!.isShinyCharmActive
	}
}
