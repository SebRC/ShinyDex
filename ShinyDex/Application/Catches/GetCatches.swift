import Foundation

struct GetCatchesQuery {
    enum Scope: Equatable {
        case species(Int)
        case collection
    }

    let scope: Scope
    let includingFailed: Bool
}

final class GetCatchesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    // A species' catches come oldest first; the collection is ordered by Pokédex number, then oldest first.
    func handle(_ query: GetCatchesQuery) -> [CatchSummary] {
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll())
        let sorted: [Catch]
        switch query.scope {
        case .species(let number):
            sorted = CatchRules.sortedOldestFirst(catchRepository.getAll(number: number))
        case .collection:
            sorted = CatchRules.sortedForCollection(catchRepository.getAll())
        }
        return sorted
            .filter { query.includingFailed || !$0.isFailed }
            .compactMap(mapper.summary)
    }
}
