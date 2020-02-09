//
//  CurrentHuntCellDelegate.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 02/07/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

public protocol CurrentHuntCellDelegate
{
	func decrementEncounters(_ sender: UIButton)
	func incrementEncounters(_ sender: UIButton)
}
