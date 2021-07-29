//
//  MoveService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation

class MoveService {
	func getMoves() -> [Move]? {
		if let url = Bundle.main.url(forResource: "moves", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let jsonData = try decoder.decode([Move].self, from: data)
				for move in jsonData {
					print(move.identifier)
				}
				return jsonData
			
			} catch {
				print("error:\(error)")
			}
		}
		return nil
	}
}
