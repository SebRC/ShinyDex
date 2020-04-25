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
	var currentHuntService: CurrentHuntService!

	@IBOutlet weak var confirmationPopup: ConfirmationPopup!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setClearBackground()
		
		setButtonActions()
		
		roundConfirmationPopupViewCorners()
    }
	
	fileprivate func setClearBackground()
	{
		view.backgroundColor = .clear
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
		currentHuntService.clear()
		performSegue(withIdentifier: "confirmUnwindSegue", sender: self)
	}
	
	fileprivate func roundConfirmationPopupViewCorners()
	{
		confirmationPopup.layer.cornerRadius = 10
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
