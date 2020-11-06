//
//  ButtonIconRight.swift
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
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	@IBOutlet weak var iconBackGroundView: UIView!
	@IBOutlet weak var backgroundView: UIView!

	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	let nibName = "ButtonIconRight"
    var contentView: UIView?
	
	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		setColors()
		setFont()
		layer.cornerRadius = CornerRadius.Standard.rawValue
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

	func setFont()
	{
		label.font = fontSettingsService.getXxSmallFont()
	}
	
	fileprivate func setColors()
	{
		contentView?.backgroundColor = colorService.getSecondaryColor()
		iconImageView.tintColor = .black
		iconBackGroundView.backgroundColor = .white
		label.backgroundColor = .white
		label.textColor = .black
	}
}
