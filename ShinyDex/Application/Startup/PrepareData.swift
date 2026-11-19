import Foundation

struct PrepareDataCommand {}

final class PrepareDataHandler {
    static let catchBackfillCompletedKey = "didBackfillCatches_v1"

    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let moveRepository: MoveRepository
    private let resourceLoader: ResourceLoader
    private let keyValueStore: KeyValueStore

    init(pokemonRepository: PokemonRepository, catchRepository: CatchRepository, moveRepository: MoveRepository, resourceLoader: ResourceLoader, keyValueStore: KeyValueStore) {
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        self.moveRepository = moveRepository
        self.resourceLoader = resourceLoader
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: PrepareDataCommand) {
        let allPokemon = pokemonRepository.getAll()
        let names = resourceLoader.lines(ofTextResource: "allGens")
        if allPokemon.isEmpty {
            insertPokemon(names: names, from: 0)
            insertInitialMoves()
            return
        }
        if allPokemon.count != names.count {
            insertPokemon(names: names, from: allPokemon.count)
        }
        backfillCatchesIfNeeded()
    }

    private func insertPokemon(names: [String], from start: Int) {
        guard start < names.count else { return }
        for number in start..<names.count {
            pokemonRepository.insert(Pokemon(newlyAddedNamed: names[number], number: number))
        }
    }

    private func insertInitialMoves() {
        guard let data = resourceLoader.data(ofResource: "initialActiveMoves", withExtension: "json"),
              let moves = try? JSONDecoder().decode([ActiveMove].self, from: data) else { return }
        moveRepository.insert(ActiveMoves(moves: moves, pressureActive: false))
    }

    private func backfillCatchesIfNeeded() {
        guard !keyValueStore.bool(forKey: PrepareDataHandler.catchBackfillCompletedKey) else { return }
        let existingCounts = CatchRules.countsByNumber(catchRepository.getAll().filter { !$0.isFailed })
        let pokemonToBackfill = CatchRules.pokemonToBackfill(from: pokemonRepository.getAll(), existingCounts: existingCounts)
        for pokemon in pokemonToBackfill {
            catchRepository.insert(Catch(pokemon: pokemon, caughtBall: pokemon.caughtBall, caughtDate: nil))
        }
        if pokemonToBackfill.isEmpty || catchRepository.save() {
            keyValueStore.set(true, forKey: PrepareDataHandler.catchBackfillCompletedKey)
        }
    }
}
