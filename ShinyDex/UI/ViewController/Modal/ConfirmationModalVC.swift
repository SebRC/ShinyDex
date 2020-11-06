//
//  ConfirmationModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 11/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class ConfirmationModalVC: UIViewController
{
	var huntService = HuntService()

	@IBOutlet weak var confirmationPopup: ConfirmationPopup!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setButtonActions()
    }
	
	fileprivate func setButtonActions()
	{
		confirmationPopup.cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
		confirmationPopup.confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
	}
	
	@objc func cancelAction(sender: UIButton!)
	{
		dismiss(animated: true)
	}
	
	@objc func confirmAction(sender: UIButton!)
	{
		huntService.clear()
		performSegue(withIdentifier: "unwindFromConfirmation", sender: self)
	}
}
