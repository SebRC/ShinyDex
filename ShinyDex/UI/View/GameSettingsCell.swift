//
//  GameSettingsCell.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsCell: UIView
{
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var actionSwitch: UISwitch!
	@IBOutlet weak var separator: UIView!

	let nibName = "GameSettingsCell"
    var contentView: UIView?

	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()
		separator.layer.cornerRadius = 5
		setUIColors()
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

	func setUIColors()
	{
		contentView?.backgroundColor = colorService.getSecondaryColor()
		separator.backgroundColor = colorService.getPrimaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		actionSwitch.onTintColor = colorService.getPrimaryColor()
		actionSwitch.thumbTintColor = colorService.getSecondaryColor()
	}

	func setFonts()
	{
		titleLabel.font = fontSettingsService.getMediumFont()
		descriptionLabel.font = fontSettingsService.getXxSmallFont()
	}
}
