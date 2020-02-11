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
	
	var settingsRepo: SettingsRepository?
	
	let nibName = "ButtonIconRight"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
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
}
