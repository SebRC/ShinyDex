import Foundation

class PokemonService {
	fileprivate let txtReader = TxtReader()
	fileprivate var pokemonRepository = PokemonRepository()

	func save(pokemon: Pokemon) {
		pokemonRepository.save(pokemon: pokemon)
	}

	func getAll() -> [Pokemon] {
		let allPokemonEntities = pokemonRepository.getAll()
		var allPokemon = [Pokemon]()
		for pokemon in allPokemonEntities {
			allPokemon.append(Pokemon(pokemonEntity: pokemon))
		}
		return allPokemon
	}

	func populateDatabase() {
		let genText = "allGens"
		let names = txtReader.readFile(textFile: genText)
		var count = 0

		for name in names {
			pokemonRepository.save(name: name, number: count)
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
        print("DIFF: \(difference)")
        print("START INDEX: \(startIndex)")
        print("NAMES: \(names)")
        for name in names {
            pokemonRepository.save(name: name, number: startIndex)
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
