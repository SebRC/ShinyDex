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
	
	var settingsRepository: SettingsRepository?
	
	let nibName = "SetEncountersView"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		
		assignSettingsRepository()
		
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
		
		encountersTextField.backgroundColor = settingsRepository?.getSecondaryColor()
		
		titleLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		nameLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		numberLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		encountersLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		
		cancelButton.backgroundColor = settingsRepository?.getSecondaryColor()
		confirmButton.backgroundColor = settingsRepository?.getSecondaryColor()
		
		buttonSeparator.backgroundColor = settingsRepository?.getMainColor()
	}
	
	fileprivate func setFonts()
	{
		titleLabel.font = settingsRepository?.getMediumFont()
		nameLabel.font = settingsRepository?.getExtraSmallFont()
		numberLabel.font = settingsRepository?.getExtraSmallFont()
		encountersLabel.font = settingsRepository?.getExtraSmallFont()
		
		cancelButton.titleLabel!.font = settingsRepository?.getExtraSmallFont()
		confirmButton.titleLabel!.font = settingsRepository?.getExtraSmallFont()
		
		encountersTextField.font = settingsRepository?.getSmallFont()
	}
	
	fileprivate func roundCorners()
	{
		nameLabel.layer.cornerRadius = 5
		numberLabel.layer.cornerRadius = 5
		encountersLabel.layer.cornerRadius = 5
		
		spriteImageView.layer.cornerRadius = 5
		
		buttonSeparator.layer.cornerRadius = 5
	}
}
