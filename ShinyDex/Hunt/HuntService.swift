import Foundation
import CoreData

class HuntService {
	fileprivate var pokemonService = PokemonService()
	fileprivate var huntRepository = HuntRepository()
	
	func getAll() -> [Hunt] {
		let pokemon = pokemonService.getAll()
		let currentHuntEntities = huntRepository.getAll()
		var hunts = [Hunt]()
		for huntEntity in currentHuntEntities {
			hunts.append(constructHunt(huntEntity: huntEntity, allPokemon: pokemon))
		}

		for hunt in hunts {
			hunt.pokemon = hunt.pokemon.sorted(by: { $0.number < $1.number})
		}
		return hunts.sorted(by: { $0.priority < $1.priority})
	}

	func save(hunt: Hunt) {
		huntRepository.save(hunt: hunt)
	}

	func clear() {
		huntRepository.clear()
	}

	func delete(hunt: Hunt) {
		huntRepository.delete(hunt: hunt)
	}

	/// Creates a hunt containing `pokemon`, placed after every existing hunt.
	@discardableResult
	func createHunt(named name: String, with pokemon: Pokemon) -> Hunt {
		let priority = (getAll().map { $0.priority }.max() ?? -1) + 1
		let hunt = Hunt(name: name, pokemon: [Pokemon](), priority: priority)
		add(pokemon: pokemon, to: hunt)
		return hunt
	}

	func add(pokemon: Pokemon, to hunt: Hunt) {
		hunt.pokemon.append(pokemon)
		hunt.indexes.append(pokemon.number)
		hunt.totalEncounters += pokemon.encounters
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntRepository.save(hunt: hunt)
	}

	fileprivate func constructHunt(huntEntity: NSManagedObject, allPokemon: [Pokemon]) -> Hunt {
		let hunt = Hunt(huntEntity: huntEntity)
		for index in hunt.indexes {
			let pokemon = allPokemon[index]
			hunt.pokemon.append(pokemon)
			hunt.totalEncounters += pokemon.encounters
		}
		return hunt
	}
}
