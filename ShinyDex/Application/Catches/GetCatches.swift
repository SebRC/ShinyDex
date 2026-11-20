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
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms()) {
        self.forms = forms
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetCatchesQuery) -> [CatchSummary] {
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        let sorted: [Catch]
        switch query.scope {
        case .species(let number):
            sorted = CatchRules.sortedOldestFirst(catchRepository.getAll(number: number))
        case .collection:
            sorted = CatchRules.sortedForCollection(catchRepository.getAll())
        }
        return sorted
            .filter { query.includingFailed || !$0.isFailed }
            .compactMap(mapper.makeSummary)
    }
}
