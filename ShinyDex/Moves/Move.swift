//
//  Move.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation

class Move: Decodable {
    var id: Int
    var identifier: String
    var generation_id: Int
    var type_id: Int
    var power: Int?
    var pp: Int?
    var accuracy: Int?
    var priority: Int
    var target_id: Int
    var damage_class_id: Int
    var effect_id: Int?
    var effect_chance: Int?
    var contest_type_id: Int?
    var contest_effect_id: Int?
    var super_contest_effect_id: Int?
    
	init(id: Int, identifier: String, generation_id: Int, type_id: Int, power: Int, pp: Int, accuracy: Int, priority: Int, target_id: Int, damage_class_id: Int, effect_id: Int, effect_chance: Int, contest_type_id: Int, contest_effect_id: Int, super_contest_effect_id: Int) {
		self.id = id
		self.identifier = identifier
		self.generation_id = generation_id
		self.type_id = type_id
		self.power = power
		self.pp = pp
		self.accuracy = accuracy
		self.priority = priority
		self.target_id = target_id
		self.damage_class_id = damage_class_id
		self.effect_id = effect_id
		self.effect_chance = effect_chance
		self.contest_type_id = contest_type_id
		self.contest_effect_id = contest_effect_id
		self.super_contest_effect_id = super_contest_effect_id
	}
}
