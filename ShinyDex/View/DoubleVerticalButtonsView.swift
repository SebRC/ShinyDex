//
//  DoubleVerticalButtonsView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 15/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

@IBDesignable
class DoubleVerticalButtonsView: UIView
{
	@IBOutlet weak var updateEncountersButton: UIButton!
	@IBOutlet weak var infoButton: UIButton!
	@IBOutlet weak var buttonSeparator: UIView!
	var settingsRepository: SettingsRepository?
	
	let nibName = "DoubleVerticalButtonsView"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		
		assignSettingsRepository()
		
		setColors()
		
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
		contentView?.backgroundColor = settingsRepository?.getSecondaryColor()
		
		buttonSeparator.backgroundColor = settingsRepository?.getMainColor()
	}
	
	fileprivate func roundCorners()
	{
		buttonSeparator.layer.cornerRadius = 5
	}
}
