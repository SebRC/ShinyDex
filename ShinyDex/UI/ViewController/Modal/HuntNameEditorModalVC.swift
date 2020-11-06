//
//  HuntNameEditorModalVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 01/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class HuntNameEditorModalVC: UIViewController
{
	var huntService = HuntService()
	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()
	var hunt: Hunt!

	@IBOutlet weak var editorView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		titleLabel.text = "Changing name of \(hunt.name)"
		titleLabel.font = fontSettingsService.getExtraSmallFont()
		titleLabel.textColor = colorService.getTertiaryColor()
		titleLabel.backgroundColor = colorService.getPrimaryColor()
		descriptionLabel.text = "Enter a new name"
		descriptionLabel.font = fontSettingsService.getExtraSmallFont()
		descriptionLabel.textColor = colorService.getTertiaryColor()
		textField.text = hunt.name
		textField.font = fontSettingsService.getSmallFont()
		textField.textColor = colorService.getTertiaryColor()
		textField.backgroundColor = colorService.getPrimaryColor()
		editorView.layer.cornerRadius = CornerRadius.Standard.rawValue
		editorView.backgroundColor = colorService.getSecondaryColor()
		confirmButton.titleLabel?.font = fontSettingsService.getSmallFont()
		confirmButton.backgroundColor = colorService.getPrimaryColor()
		confirmButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		cancelButton.titleLabel?.font = fontSettingsService.getSmallFont()
		cancelButton.backgroundColor = colorService.getPrimaryColor()
		cancelButton.setTitleColor(colorService.getTertiaryColor(), for: .normal)
		horizontalSeparator.backgroundColor = colorService.getSecondaryColor()
		verticalSeparator.backgroundColor = colorService.getSecondaryColor()
    }
	
	@IBAction func confirmpressed(_ sender: Any)
	{
		hunt.name = textField.text ?? "New Hunt"
		huntService.save(hunt: hunt)
		performSegue(withIdentifier: "unwindFromNameEditor", sender: self)
	}
	
	@IBAction func cancelPressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
}
