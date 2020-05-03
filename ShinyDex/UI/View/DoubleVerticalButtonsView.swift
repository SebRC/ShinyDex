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
	fileprivate var colorService: ColorService?
	
	let nibName = "DoubleVerticalButtonsView"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		colorService = ColorService()
		
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
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = colorService!.getSecondaryColor()
		
		buttonSeparator.backgroundColor = colorService!.getPrimaryColor()
		
		infoButton.tintColor = colorService!.getTertiaryColor()
		updateEncountersButton.tintColor = colorService!.getTertiaryColor()
	}
	
	fileprivate func roundCorners()
	{
		buttonSeparator.layer.cornerRadius = 10
	}
}
