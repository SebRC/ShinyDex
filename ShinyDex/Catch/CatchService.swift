import Foundation

class CatchService {
	static let backfillCompletedKey = "didBackfillCatches_v1"

	fileprivate let catchRepository = CatchRepository()
	fileprivate let pokemonService = PokemonService()
	fileprivate let userDefaults: UserDefaults

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	func getAll() -> [Catch] {
		return catchRepository.getAll().map { Catch(catchEntity: $0) }
	}

	func getCatches(for pokemon: Pokemon) -> [Catch] {
		return CatchRules.sortedOldestFirst(catchRepository.getAll(number: pokemon.number).map { Catch(catchEntity: $0) })
	}

	func getCountsByNumber() -> [Int: Int] {
		return CatchRules.countsByNumber(getAll())
	}

	func logCatch(pokemon: Pokemon, caughtBall: String) {
		catchRepository.insert(catchToInsert: Catch(pokemon: pokemon, caughtBall: caughtBall, caughtDate: Date()))
		if catchRepository.save() {
			syncCaughtBall(pokemon: pokemon)
		}
	}

	func update(caught: Catch, pokemon: Pokemon, applying changes: (Catch) -> Void) {
		changes(caught)
		catchRepository.update(catchToUpdate: caught)
		if catchRepository.save() {
			syncCaughtBall(pokemon: pokemon)
		}
		else {
			caught.revertToSaved()
		}
	}

	func delete(catchToDelete: Catch, pokemon: Pokemon) {
		catchRepository.delete(catchToDelete: catchToDelete)
		if catchRepository.save() {
			syncCaughtBall(pokemon: pokemon)
		}
	}

	@discardableResult
	func removeLatestCatch(pokemon: Pokemon) -> Bool {
		guard let latestCatch = getCatches(for: pokemon).last else {
			return false
		}
		delete(catchToDelete: latestCatch, pokemon: pokemon)
		return true
	}

	func backfillIfNeeded() {
		if userDefaults.bool(forKey: CatchService.backfillCompletedKey) {
			return
		}
		let pokemonToBackfill = CatchRules.pokemonToBackfill(from: pokemonService.getAll(), existingCounts: getCountsByNumber())
		for pokemon in pokemonToBackfill {
			catchRepository.insert(catchToInsert: Catch(pokemon: pokemon, caughtBall: pokemon.caughtBall, caughtDate: nil))
		}
		if pokemonToBackfill.isEmpty || catchRepository.save() {
			userDefaults.set(true, forKey: CatchService.backfillCompletedKey)
		}
	}

	// PokemonEntity.caughtBall mirrors the latest catch, so existing screens and older builds keep showing the right ball.
	fileprivate func syncCaughtBall(pokemon: Pokemon) {
		let catches = getCatches(for: pokemon)
		pokemon.caughtBall = CatchRules.latestBall(of: catches)
		pokemon.caughtDescription = catches.isEmpty ? "Not Caught" : "Caught"
		pokemonService.save(pokemon: pokemon)
	}
}
