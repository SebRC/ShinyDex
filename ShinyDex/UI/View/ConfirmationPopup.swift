//
//  ConfirmationPopup.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 10/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ConfirmationPopup: UIView
{
	let nibName = "ConfirmationPopup"
    var contentView: UIView?
	
	var colorService: ColorService?
	var fontSettingsService: FontSettingsService?
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		colorService = ColorService()
		fontSettingsService = FontSettingsService()
		setConfirmationPopupFonts()
		setColors()
		roundSeparatorCorners()
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
	
	fileprivate func setConfirmationPopupFonts()
	{
		cancelButton.titleLabel?.font = fontSettingsService!.getSmallFont()
		confirmButton.titleLabel?.font = fontSettingsService!.getSmallFont()
		titleLabel.font = fontSettingsService!.getSmallFont()
		descriptionLabel.font = fontSettingsService!.getExtraSmallFont()
	}
	
	fileprivate func setColors()
	{
		cancelButton.backgroundColor = colorService?.getPrimaryColor()
		titleLabel.backgroundColor = colorService?.getPrimaryColor()
		titleLabel.textColor = colorService?.getTertiaryColor()
		descriptionLabel.textColor = colorService?.getTertiaryColor()
		contentView?.backgroundColor = colorService?.getSecondaryColor()
		buttonSeparator.backgroundColor = colorService?.getSecondaryColor()
		confirmButton.backgroundColor = colorService?.getPrimaryColor()
		confirmButton.setTitleColor(colorService?.getTertiaryColor(), for: .normal)
		cancelButton.setTitleColor(colorService?.getTertiaryColor(), for: .normal)
	}
	
	fileprivate func roundSeparatorCorners()
	{
		buttonSeparator.layer.cornerRadius = 5
	}
}
