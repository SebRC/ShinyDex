//
//  PokemonCellDelegate.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 26/03/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

protocol PokemonCellDelegate : class {
	func changeCaughtButtonPressed(_ sender: UIButton)
	
	func addToHuntPressed(_ sender: UIButton)
}
