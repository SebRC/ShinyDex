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
    var contentView:UIView?
	var currentHuntRepository = CurrentHuntRepository.currentHuntRepositorySingleton
	var tableview: UITableView?
	var clearHuntButton: UIBarButtonItem?
	
	var settingsRepository: SettingsRepository?
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		
		assignSettingsRepository()
		
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
	
	fileprivate func assignSettingsRepository()
	{
		if settingsRepository == nil
		{
			settingsRepository = SettingsRepository.settingsRepositorySingleton
		}
	}
	
	fileprivate func setConfirmationPopupFonts()
	{
		cancelButton.titleLabel?.font = settingsRepository!.getSmallFont()
		confirmButton.titleLabel?.font = settingsRepository!.getSmallFont()
		titleLabel.font = settingsRepository!.getSmallFont()
		descriptionLabel.font = settingsRepository!.getExtraSmallFont()
	}
	
	fileprivate func setColors()
	{
		cancelButton.backgroundColor = settingsRepository?.getSecondaryColor()
		titleLabel.backgroundColor = settingsRepository?.getSecondaryColor()
		contentView?.backgroundColor = settingsRepository?.getMainColor()
		buttonSeparator.backgroundColor = settingsRepository?.getMainColor()
		confirmButton.backgroundColor = settingsRepository?.getSecondaryColor()
	}
	
	fileprivate func roundSeparatorCorners()
	{
		buttonSeparator.layer.cornerRadius = 5
	}
}
