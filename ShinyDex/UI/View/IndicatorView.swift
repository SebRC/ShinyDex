//
//  IndicatorView.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 13/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class IndicatorView: UIView {
	let nibName = "IndicatorView"
    var contentView: UIView?
	fileprivate var colorService = ColorService()
	fileprivate var fontSettingsService = FontSettingsService()

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var pokemonImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)
		titleLabel.textColor = colorService.getTertiaryColor()
		layer.cornerRadius = CornerRadius.Standard
		contentView?.backgroundColor = colorService.getSecondaryColor()
		titleLabel.font = fontSettingsService.getXxSmallFont()
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
}
