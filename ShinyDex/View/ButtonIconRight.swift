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
class ButtonIconRight: UIView
{
	
	
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var button: UIButton!
	var settingsRepo: SettingsRepository?
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var iconBackGroundView: UIView!
	@IBOutlet weak var backgroundView: UIView!
	
	let nibName = "ButtonIconRight"
    var contentView: UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		
		assignSettingsRepository()
		
		setColors()
		
		setFonts()
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
			settingsRepo = SettingsRepository.settingsRepositorySingleton
		}
	}
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = settingsRepo?.getSecondaryColor()
		iconImageView.tintColor = UIColor.black
		iconBackGroundView.backgroundColor = UIColor.white
		verticalSeparator.backgroundColor = UIColor.black
		horizontalSeparator.backgroundColor = UIColor.black
		label.backgroundColor = UIColor.white
		label.textColor = UIColor.black
	}
	
	fileprivate func setFonts()
	{
		label.font = settingsRepo?.getXxSmallFont()
	}
}
