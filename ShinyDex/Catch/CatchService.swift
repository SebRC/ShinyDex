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
		return getAllIncludingFailed().filter { !$0.isFailed }
	}

	func getAllIncludingFailed() -> [Catch] {
		return catchRepository.getAll().map { Catch(catchEntity: $0) }
	}

	func getCatches(for pokemon: Pokemon) -> [Catch] {
		return getCatchesIncludingFailed(for: pokemon).filter { !$0.isFailed }
	}

	func getCatchesIncludingFailed(for pokemon: Pokemon) -> [Catch] {
		return CatchRules.sortedOldestFirst(catchRepository.getAll(number: pokemon.number).map { Catch(catchEntity: $0) })
	}

	func getCountsByNumber() -> [Int: Int] {
		return CatchRules.countsByNumber(getAll())
	}

	func logCatch(pokemon: Pokemon, caughtBall: String, caughtDate: Date = Date()) {
		catchRepository.insert(catchToInsert: Catch(pokemon: pokemon, caughtBall: caughtBall, caughtDate: caughtDate))
		if catchRepository.save() {
			syncCaughtBall(pokemon: pokemon)
		}
	}

	func logFailed(pokemon: Pokemon, date: Date = Date()) {
		catchRepository.insert(catchToInsert: Catch(pokemon: pokemon, caughtBall: CatchRules.noBall, caughtDate: date, isFailed: true))
		catchRepository.save()
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

	@discardableResult
	func evolve(caught: Catch, from pokemon: Pokemon, into target: Pokemon) -> Bool {
		let originalNumber = caught.evolvedFrom ?? caught.number
		caught.number = target.number
		caught.evolvedFrom = originalNumber == target.number ? nil : originalNumber
		catchRepository.update(catchToUpdate: caught)
		guard catchRepository.save() else {
			caught.revertToSaved()
			return false
		}
		syncCaughtBall(pokemon: pokemon)
		syncCaughtBall(pokemon: target)
		return true
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
