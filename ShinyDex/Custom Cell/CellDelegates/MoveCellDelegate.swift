//
//  MoveCellDelegate.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 30/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

protocol MoveCellDelegate {
	func incrementPressed(_ sender: UIButton)
	func decrementPressed(_ sender: UIButton)
}
