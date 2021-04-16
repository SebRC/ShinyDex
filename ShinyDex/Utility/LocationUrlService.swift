//
//  LocationUrlService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class LocationUrlService {
	fileprivate let generationPrefixes = [0: "sm", 1: "gs", 2: "gs", 3: "dp", 4: "dp", 5: "bw", 6: "xy", 7: "sm", 8: "swsh"]
	fileprivate let generationRanges = [1: 0..<151, 2: 151..<251, 3: 251..<386, 4: 386..<493, 5: 493..<649, 6: 649..<721, 7: 721..<807, 8: 807..<892]

	func getUrl(generation: Int, pokemon: Pokemon) -> String {
		let minimumGeneration = getMinimumGeneration(dexNumber: pokemon.number)
		let isGeneration8 = generation == 8
		let numberPrefix = getNumberPrefix(dexNumber: pokemon.number)
		let generationIdentifier = generation < minimumGeneration
			? generationPrefixes[minimumGeneration]!
			: generationPrefixes[generation]!

		return "https://serebii.net/pokedex-\(generationIdentifier)/\(isGeneration8 ? pokemon.name.lowercased() : numberPrefix)\(isGeneration8 ? "" : ".shtml")"
	}

	fileprivate func getMinimumGeneration(dexNumber: Int) -> Int {
		for entry in generationRanges {
			if (entry.value ~= dexNumber) {
				return entry.key
			}
		}
		return 7
	}

	fileprivate func getNumberPrefix(dexNumber: Int) -> String {
		var numberPrefix = ""
		if (dexNumber < 9) {
			numberPrefix = "00"
		}
		else if (dexNumber >= 9  && dexNumber < 99) {
			numberPrefix = "0"
		}
		numberPrefix += String(dexNumber + 1)
		return numberPrefix
	}
}
