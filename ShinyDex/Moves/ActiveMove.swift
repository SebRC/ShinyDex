//
//  ActiveMove.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ActiveMove: Encodable, Decodable {

	var name: String
	var maxPP: Int
	var remainingPP: Int
	var type: String

	init(name: String, maxPP: Int, remainingPP: Int, type: String) {
		self.name = name
		self.maxPP = maxPP
		self.remainingPP = remainingPP
		self.type = type
	}
}
