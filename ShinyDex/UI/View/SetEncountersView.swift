//
//  SetEncountersView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class SetEncountersView: UIView
{
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var encountersTextField: UITextField!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var spriteImageView: UIImageView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	
	var fontSettingsService: FontSettingsService?
	var colorService: ColorService?
	
	let nibName = "SetEncountersView"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		fontSettingsService = FontSettingsService()

		colorService = ColorService()
		
		setColors()
		
		setFonts()
		
		roundCorners()
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

		spriteImageView.backgroundColor = colorService!.getSecondaryColor()
		
		encountersTextField.backgroundColor = colorService!.getSecondaryColor()
		encountersTextField.textColor = colorService!.getTertiaryColor()
		encountersTextField.attributedPlaceholder = NSAttributedString(string: "Set Encounters",
																	   attributes: [NSAttributedString.Key.foregroundColor: colorService!.getTertiaryColor() as Any])
		
		titleLabel.backgroundColor = colorService!.getSecondaryColor()
		titleLabel.textColor = colorService!.getTertiaryColor()
		
		nameLabel.backgroundColor = colorService!.getSecondaryColor()
		nameLabel.textColor = colorService!.getTertiaryColor()
		
		numberLabel.backgroundColor = colorService!.getSecondaryColor()
		numberLabel.textColor = colorService!.getTertiaryColor()
		
		encountersLabel.backgroundColor = colorService!.getSecondaryColor()
		encountersLabel.textColor = colorService!.getTertiaryColor()
		
		cancelButton.backgroundColor = colorService!.getSecondaryColor()
		cancelButton.setTitleColor(colorService!.getTertiaryColor(), for: .normal)
		
		confirmButton.backgroundColor = colorService!.getSecondaryColor()
		confirmButton.setTitleColor(colorService!.getTertiaryColor(), for: .normal)
		
		buttonSeparator.backgroundColor = colorService!.getPrimaryColor()
	}
	
	fileprivate func setFonts()
	{
		titleLabel.font = fontSettingsService!.getMediumFont()
		nameLabel.font = fontSettingsService!.getExtraSmallFont()
		numberLabel.font = fontSettingsService!.getExtraSmallFont()
		encountersLabel.font = fontSettingsService!.getExtraSmallFont()
		
		cancelButton.titleLabel!.font = fontSettingsService!.getExtraSmallFont()
		confirmButton.titleLabel!.font = fontSettingsService!.getExtraSmallFont()
		
		encountersTextField.font = fontSettingsService!.getSmallFont()
	}
	
	fileprivate func roundCorners()
	{
		nameLabel.layer.cornerRadius = 10
		numberLabel.layer.cornerRadius = 10
		encountersLabel.layer.cornerRadius = 10
		
		spriteImageView.layer.cornerRadius = 10
		
		buttonSeparator.layer.cornerRadius = 10
	}
}
