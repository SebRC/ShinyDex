import Foundation

struct GetAllPokemonQuery {}

final class GetAllPokemonHandler {
    private let pokemonRepository: PokemonRepository

    init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetAllPokemonQuery) -> [PokemonSummary] {
        return pokemonRepository.getAll().map(PokemonSummary.init)
    }
}
