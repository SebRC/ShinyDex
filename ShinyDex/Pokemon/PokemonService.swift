//
//  PokemonService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 24/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class PokemonService
{
	fileprivate let txtReader = TxtReader()
	fileprivate var pokemonRepository = PokemonRepository()

	func save(pokemon: Pokemon)
	{
		pokemonRepository.save(pokemon: pokemon)
	}

	func getAll() -> [Pokemon]
	{
		let allPokemonEntities = pokemonRepository.getAll()
		var allPokemon = [Pokemon]()
		for pokemon in allPokemonEntities
		{
			allPokemon.append(Pokemon(pokemonEntity: pokemon))
		}
		return allPokemon
	}

	func populateDatabase()
	{
		let genText = "allGens"
		let names = txtReader.linesFromResourceForced(textFile: genText)
		var count = 0

		for name in names
		{
			pokemonRepository.save(name: name, number: count)
			count += 1
		}
	}
}
