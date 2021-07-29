//
//  MoveView.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MoveView: UIView {
	let nibName = "MoveView"
	var contentView: UIView?

	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var ppLabel: UILabel!
	@IBOutlet weak var decrementButton: UIButton!
	@IBOutlet weak var incrementButton: UIButton!
	@IBOutlet weak var typeImage: UIImageView!
	@IBOutlet weak var typeLabel: UILabel!
	

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initContentView(nibName: nibName, contentView: &contentView)
		setConfirmationPopupFonts()
		setColors()
		layer.cornerRadius = CornerRadius.Standard.rawValue
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initContentView(nibName: nibName, contentView: &contentView)
	}

	fileprivate func setConfirmationPopupFonts() {
	}

	fileprivate func setColors() {
	}
}
