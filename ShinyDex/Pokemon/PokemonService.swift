import Foundation

class PokemonService {
	fileprivate let txtReader = TxtReader()
	fileprivate let pokemonRepository: PokemonRepository = CoreDataPokemonRepository()

	func save(pokemon: Pokemon) {
		pokemonRepository.save(pokemon)
	}

	func getAll() -> [Pokemon] {
		return pokemonRepository.getAll()
	}

	func populateDatabase() {
		let genText = "allGens"
		let names = txtReader.readFile(textFile: genText)
		var count = 0

		for name in names {
			pokemonRepository.insert(Pokemon(newlyAddedNamed: name, number: count))
			count += 1
		}
	}
    
    func migrate() {
        let allPokemon = getAll()
        let genText = "allGens"
        let allNames = txtReader.readFile(textFile: genText)
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
