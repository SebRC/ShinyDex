//
//  IncrementVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 07/08/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class IncrementVC: UIViewController
{
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var buttonBackgroundView: UIView!
	@IBOutlet weak var buttonSeparatorView: UIView!
	@IBOutlet weak var incrementSegmentedControl: UISegmentedControl!
	


	override func viewDidLoad()
	{
        super.viewDidLoad()
    }
	@IBAction func incrementChanged(_ sender: Any) {
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
	}
	@IBAction func confirmPressed(_ sender: Any) {
	}
}
