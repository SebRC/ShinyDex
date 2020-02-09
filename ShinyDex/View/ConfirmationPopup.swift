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
	var currentHuntRepo = CurrentHuntRepository.currentHuntRepoSingleton
	var tableview: UITableView?
	var clearHuntButton: UIBarButtonItem?
	
	var settingsRepo: SettingsRepository?
	
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
		if settingsRepo == nil
		{
			settingsRepo = SettingsRepository.settingsRepoSingleton
		}
	}
	
	fileprivate func setConfirmationPopupFonts()
	{
		cancelButton.titleLabel?.font = settingsRepo!.getSmallFont()
		confirmButton.titleLabel?.font = settingsRepo!.getSmallFont()
		titleLabel.font = settingsRepo!.getSmallFont()
		descriptionLabel.font = settingsRepo!.getExtraSmallFont()
	}
	
	fileprivate func setColors()
	{
		cancelButton.backgroundColor = settingsRepo?.getSecondaryColor()
		titleLabel.backgroundColor = settingsRepo?.getSecondaryColor()
		contentView?.backgroundColor = settingsRepo?.getMainColor()
		buttonSeparator.backgroundColor = settingsRepo?.getMainColor()
		confirmButton.backgroundColor = settingsRepo?.getSecondaryColor()
	}
	
	fileprivate func roundSeparatorCorners()
	{
		buttonSeparator.layer.cornerRadius = 5
	}
}
