//
//  MoveTypes.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 30/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class MoveTypes {
	static var Types = [1: "Normal", 2: "Fighting", 3: "Flying", 4: "Poison", 5: "Ground", 6: "Rock",
						7: "Bug", 8: "Ghost", 9: "Steel", 10: "Fire", 11: "Water", 12: "Grass",
						13: "Electric", 14: "Psychic", 15: "Ice", 16: "Dragon", 17: "Dark",
						18: "Fairy"]

	static var colors = ["Normal": UIColor(netHex: 0x9199a1), "Fighting": UIColor(netHex: 0xcf4069), "Flying": UIColor(netHex: 0x8ea9df),
						 "Poison": UIColor(netHex: 0xaa66cc), "Ground": UIColor(netHex: 0xdb7645), "Rock": UIColor(netHex: 0xc7b78a),
						 "Bug": UIColor(netHex: 0x91c22e), "Ghost": UIColor(netHex: 0x5568aa), "Steel": UIColor(netHex: 0x598fa2),
						 "Fire": UIColor(netHex: 0xff9d55), "Water": UIColor(netHex: 0x4d91d7), "Grass": UIColor(netHex: 0x61bb59),
						 "Electric": UIColor(netHex: 0xf3d33c), "Psychic": UIColor(netHex: 0xfb7075), "Ice": UIColor(netHex: 0x71cfbe),
						 "Dragon": UIColor(netHex: 0x0a6dc8), "Dark": UIColor(netHex: 0x595265), "Fairy": UIColor(netHex: 0xef8fe7)]
}
