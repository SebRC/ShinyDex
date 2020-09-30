//
//  LocationUrlService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class LocationUrlService
{
	func getUrl(generation: Int, pokemon: Pokemon) -> String
	{
		let isGeneration8 = generation == 8
		let numberPrefix = getNumberPrefix(dexNumber: pokemon.number)
		let generationIdentifier = getGenerationIdentifier(generation: generation)

		return "https://serebii.net/pokedex-\(generationIdentifier)/\(isGeneration8 ? pokemon.name.lowercased() : numberPrefix)\(isGeneration8 ? "" : ".shtml")"
	}

	fileprivate func getNumberPrefix(dexNumber: Int) -> String
	{
		var numberPrefix = ""

		if dexNumber < 9
		{
			numberPrefix = "00"
		}
		else if dexNumber >= 9  && dexNumber < 99
		{
			numberPrefix = "0"
		}

		numberPrefix += String(dexNumber + 1)

		return numberPrefix
	}

	fileprivate func getGenerationIdentifier(generation: Int) -> String
	{
		switch generation
		{
		case 2:
			return "gs"
		case 4:
			return "dp"
		case 5:
			return "bw"
		case 6:
			return "xy"
		case 8:
			return "swsh"
		default:
			return "sm"
		}
	}
}
