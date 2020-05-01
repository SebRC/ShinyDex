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
	var huntService: HuntService!
	var colorService: ColorService!
	var fontSettingsService: FontSettingsService!
	var hunt: Hunt!

	@IBOutlet weak var editorView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var verticalSeparator: UIView!
	@IBOutlet weak var horizontalSeparator: UIView!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		titleLabel.text = "Changing name of \(hunt.name)"
		descriptionLabel.text = "Enter a new name"
		textField.text = hunt.name
    }
	
	@IBAction func cancelpressed(_ sender: Any)
	{
		dismiss(animated: true)
	}
	
	@IBAction func confirmPressed(_ sender: Any)
	{
		hunt.name = textField.text ?? "New Hunt"
		huntService.save(hunt: hunt)
		performSegue(withIdentifier: "huntNameEditorUnwind", sender: self)
	}
}
