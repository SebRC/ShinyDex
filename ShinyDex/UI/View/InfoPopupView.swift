//
//  InfoPopupView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class InfoPopupView: UIView
{
	let nibName = "InfoPopupView"
    var contentView:UIView?
	
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var spriteImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var encountersTitleLabel: UILabel!
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
	@IBOutlet weak var generationBackgroundView: UIView!
	@IBOutlet weak var lureSwitch: UISwitch!
	@IBOutlet weak var lureLabel: UILabel!
	@IBOutlet weak var imagesBackgroundView: UIView!
	@IBOutlet weak var imageSeparator: UIView!
	@IBOutlet weak var encountersBackgroundView: UIView!
	@IBOutlet weak var encountersLabel: UILabel!

	var switchStateService = SwitchStateService()
	var fontSettingsService: FontSettingsService?
	var colorService: ColorService?
	var huntStateService: HuntStateService?
	var probability: Double?
	var encounters: Int?

	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		fontSettingsService = FontSettingsService()

		colorService = ColorService()

		huntStateService = HuntStateService()
		
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
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = colorService!.getPrimaryColor()

		infoLabel.backgroundColor = colorService!.getSecondaryColor()
		infoLabel.textColor = colorService!.getTertiaryColor()
		
		nameLabel.backgroundColor = colorService!.getSecondaryColor()
		nameLabel.textColor = colorService!.getTertiaryColor()
		
		numberLabel.backgroundColor = colorService!.getSecondaryColor()
		numberLabel.textColor = colorService!.getTertiaryColor()

		encountersTitleLabel.textColor = colorService!.getTertiaryColor()
		encountersLabel.textColor = colorService!.getTertiaryColor()
		encountersBackgroundView.backgroundColor = colorService!.getSecondaryColor()
		
		shinyOddsLabel.backgroundColor = colorService!.getSecondaryColor()
		shinyOddsLabel.textColor = colorService!.getTertiaryColor()
		
		probabilityLabel.backgroundColor = colorService!.getSecondaryColor()
		probabilityLabel.textColor = colorService!.getTertiaryColor()
		
		shinyCharmLabel.backgroundColor = colorService!.getSecondaryColor()
		shinyCharmLabel.textColor = colorService!.getTertiaryColor()

		lureLabel.backgroundColor = colorService!.getSecondaryColor()
		lureLabel.textColor = colorService!.getTertiaryColor()
		
		generationBackgroundView.backgroundColor = colorService!.getSecondaryColor()
		generationLabel.textColor = colorService!.getTertiaryColor()
		
		generationSegmentedControl.backgroundColor = colorService!.getSecondaryColor()
		generationSegmentedControl.tintColor = colorService!.getPrimaryColor()
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService!.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService!.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		cancelButton.backgroundColor = colorService!.getSecondaryColor()
		cancelButton.setTitleColor(colorService!.getTertiaryColor(), for: .normal)
		
		saveButton.backgroundColor = colorService!.getSecondaryColor()
		saveButton.setTitleColor(colorService!.getTertiaryColor(), for: .normal)
		
		buttonSeparator.backgroundColor = colorService!.getPrimaryColor()
		
		shinyCharmSwitch.thumbTintColor = colorService!.getPrimaryColor()
		shinyCharmSwitch.onTintColor = colorService!.getSecondaryColor()

		lureSwitch.thumbTintColor = colorService!.getPrimaryColor()
		lureSwitch.onTintColor = colorService!.getSecondaryColor()

		imagesBackgroundView.backgroundColor = colorService!.getSecondaryColor()
		imageSeparator.backgroundColor = colorService!.getPrimaryColor()
	}
	
	fileprivate func setFonts()
	{
		infoLabel.font = fontSettingsService!.getXxLargeFont()
		nameLabel.font = fontSettingsService!.getExtraSmallFont()
		numberLabel.font = fontSettingsService!.getExtraSmallFont()
		encountersTitleLabel.font = fontSettingsService!.getExtraSmallFont()
		shinyOddsLabel.font = fontSettingsService!.getExtraSmallFont()
		probabilityLabel.font = fontSettingsService!.getExtraSmallFont()
		shinyCharmLabel.font = fontSettingsService!.getExtraSmallFont()
		lureLabel.font = fontSettingsService!.getExtraSmallFont()
		generationLabel.font = fontSettingsService!.getExtraSmallFont()
		encountersLabel.font = fontSettingsService!.getMediumFont()
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService!.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService!.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
		
		cancelButton.titleLabel!.font = fontSettingsService!.getExtraSmallFont()
		saveButton.titleLabel!.font = fontSettingsService!.getExtraSmallFont()
	}
	
	fileprivate func roundCorners()
	{
		nameLabel.layer.cornerRadius = 10
		numberLabel.layer.cornerRadius = 10
		generationBackgroundView.layer.cornerRadius = 10
		shinyOddsLabel.layer.cornerRadius = 10
		probabilityLabel.layer.cornerRadius = 10
		shinyCharmLabel.layer.cornerRadius = 10
		lureLabel.layer.cornerRadius = 10
		buttonSeparator.layer.cornerRadius = 10
		imageSeparator.layer.cornerRadius = 10
		imagesBackgroundView.layer.cornerRadius = 10
		encountersBackgroundView.layer.cornerRadius = 10
	}
	
	fileprivate func setGenerationSegmentedControlSelectedIndex()
	{
		let huntState = huntStateService?.get()
		generationSegmentedControl.selectedSegmentIndex = huntState!.generation
	}
	
	fileprivate func setShinyCharmActiveState()
	{
		let huntState = huntStateService?.get()
		shinyCharmSwitch.isOn = huntState!.isShinyCharmActive
	}
}
