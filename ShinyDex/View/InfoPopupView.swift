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
	var settingsRepository: SettingsRepository?
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
		if settingsRepository == nil
		{
			settingsRepository = SettingsRepository.settingsRepositorySingleton
		}
	}
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = settingsRepository?.getMainColor()

		spriteImageView.backgroundColor = settingsRepository?.getSecondaryColor()
		pokeballImageView.backgroundColor = settingsRepository?.getSecondaryColor()
		
		infoLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		nameLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		numberLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		encountersLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		shinyOddsLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		probabilityLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		shinyCharmLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		generationLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		
		generationSegmentedControl.backgroundColor = settingsRepository?.getSecondaryColor()
		generationSegmentedControl.tintColor = settingsRepository?.getMainColor()
		
		cancelButton.backgroundColor = settingsRepository?.getSecondaryColor()
		saveButton.backgroundColor = settingsRepository?.getSecondaryColor()
		
		buttonSeparator.backgroundColor = settingsRepository?.getMainColor()
		
		shinyCharmSwitch.thumbTintColor = settingsRepository?.getMainColor()
		shinyCharmSwitch.onTintColor = settingsRepository?.getSecondaryColor()
	}
	
	fileprivate func setFonts()
	{
		infoLabel.font = settingsRepository?.getXxLargeFont()
		nameLabel.font = settingsRepository?.getExtraSmallFont()
		numberLabel.font = settingsRepository?.getExtraSmallFont()
		encountersLabel.font = settingsRepository?.getExtraSmallFont()
		shinyOddsLabel.font = settingsRepository?.getExtraSmallFont()
		probabilityLabel.font = settingsRepository?.getExtraSmallFont()
		shinyCharmLabel.font = settingsRepository?.getExtraSmallFont()
		generationLabel.font = settingsRepository?.getExtraSmallFont()
		
		generationSegmentedControl.setTitleTextAttributes(settingsRepository!.getFontAsNSAttibutedStringKey(fontSize: settingsRepository!.extraSmallFontSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		cancelButton.titleLabel!.font = settingsRepository?.getExtraSmallFont()
		saveButton.titleLabel!.font = settingsRepository?.getExtraSmallFont()
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
		generationSegmentedControl.selectedSegmentIndex = settingsRepository!.generation
	}
	
	fileprivate func setShinyCharmActiveState()
	{
		shinyCharmSwitch.isOn = settingsRepository!.isShinyCharmActive
	}
}
