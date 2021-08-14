//
//  GameSettingsCell.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsCell: UIView {
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()

	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var actionSwitch: UISwitch!
	@IBOutlet weak var separator: UIView!

	let nibName = "GameSettingsCell"
    var contentView: UIView?

	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
		separator.layer.cornerRadius = CornerRadius.Standard
		setUIColors()
		setFonts()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }

	func setUIColors() {
		contentView?.backgroundColor = colorService.getPrimaryColor()
		separator.backgroundColor = colorService.getSecondaryColor()
		titleLabel.textColor = colorService.getTertiaryColor()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		actionSwitch.onTintColor = colorService.getSecondaryColor()
		actionSwitch.thumbTintColor = colorService.getPrimaryColor()
	}

	func setFonts() {
		titleLabel.font = fontSettingsService.getMediumFont()
		descriptionLabel.font = fontSettingsService.getXxSmallFont()
	}
}
