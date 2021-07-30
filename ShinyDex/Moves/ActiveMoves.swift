//
//  ActiveMoves.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ActiveMoves: NSObject {
	var activeMovesEntity: NSManagedObject
	var json: String

	init(moveEntity: NSManagedObject) {
		self.activeMovesEntity = moveEntity
		self.json = moveEntity.value(forKey: "json") as! String
	}

	init(json: String) {
		self.activeMovesEntity = NSManagedObject()
		self.json = json
	}
}
