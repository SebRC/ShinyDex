import Foundation

struct GetAllPokemonQuery {
    var obtainableFor: Games? = nil
}

final class GetAllPokemonHandler {
    private let pokemonRepository: PokemonRepository

    init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetAllPokemonQuery) -> [PokemonSummary] {
        let all = pokemonRepository.getAll()
        guard let game = query.obtainableFor else { return all.map(PokemonSummary.init) }
        return all.filter { TradeGroups.canObtain($0.number, for: game) }.map(PokemonSummary.init)
    }
}
