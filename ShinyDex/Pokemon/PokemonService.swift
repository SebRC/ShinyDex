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

	func applyToAll(pokemon: Pokemon, allPokemon: [Pokemon]) {
		for pokemonEntity in allPokemon {
			pokemonEntity.generation = pokemon.generation
			pokemonEntity.isShinyCharmActive = pokemon.isShinyCharmActive
			pokemonEntity.shinyOdds = pokemon.shinyOdds
			pokemonEntity.huntMethod = pokemon.huntMethod
			pokemonEntity.useIncrementInHunts = pokemon.useIncrementInHunts
            pokemonEntity.game = pokemon.game
			save(pokemon: pokemonEntity)
		}
	}

	func deleteAll() {
		pokemonRepository.deleteAll()
	}
}
