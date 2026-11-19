import Foundation

class PokemonService {
	fileprivate let resourceLoader: ResourceLoader = AppContainer.shared.resourceLoader
	fileprivate let pokemonRepository: PokemonRepository = AppContainer.shared.pokemonRepository

	func save(pokemon: Pokemon) {
		pokemonRepository.save(pokemon)
	}

	func getAll() -> [Pokemon] {
		return pokemonRepository.getAll()
	}

	func populateDatabase() {
		let genText = "allGens"
		let names = resourceLoader.lines(ofTextResource: genText)
		var count = 0

		for name in names {
			pokemonRepository.insert(Pokemon(newlyAddedNamed: name, number: count))
			count += 1
		}
	}
    
    func migrate() {
        let allPokemon = getAll()
        let genText = "allGens"
        let allNames = resourceLoader.lines(ofTextResource: genText)
        let difference = allNames.count - allPokemon.count
        var startIndex = allNames.count - difference
        let names = Array(allNames[startIndex..<allNames.count])
        for name in names {
            pokemonRepository.insert(Pokemon(newlyAddedNamed: name, number: startIndex))
            startIndex += 1
        }
        
    }

	func applyToAll(pokemon: Pokemon, allPokemon: [Pokemon]) {
		for pokemonEntity in allPokemon {
			pokemonEntity.generation = pokemon.generation
			pokemonEntity.isShinyCharmActive = pokemon.isShinyCharmActive
			pokemonEntity.shinyOdds = pokemon.shinyOdds
			pokemonEntity.huntMethod = pokemon.huntMethod
            pokemonEntity.game = pokemon.game
			save(pokemon: pokemonEntity)
		}
	}

	func deleteAll() {
		pokemonRepository.deleteAll()
	}
}
