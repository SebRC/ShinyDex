//
//  PopupView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PopupView: UIView
{
	let nibName = "PopupView"
    var contentView:UIView?
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	@IBOutlet weak var actionLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
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
		contentView?.backgroundColor = colorService.getSecondaryColor()
		actionLabel.textColor = colorService.getTertiaryColor()
		iconImageView.tintColor = colorService.getTertiaryColor()
		actionLabel.font = fontSettingsService.getSmallFont()
		contentView?.layer.cornerRadius = CornerRadius.Standard.rawValue
    }
	
    func loadViewFromNib() -> UIView?
	{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
