//
//  RearrangeCellDelegate.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 16/11/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

public protocol RearrangeCellDelegate {
	func moveUp(_ sender: UIButton)
	func moveDown(_ sender: UIButton)
}
