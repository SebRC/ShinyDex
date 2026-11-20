import Foundation

struct GetPokedexQuery {
    let region: Int
}

struct PokedexEntry: Equatable {
    let number: Int
    let name: String
    let caughtBall: String
    let isBeingHunted: Bool
    let catchCount: Int
}

struct Pokedex: Equatable {
    let entries: [PokedexEntry]
}

final class GetPokedexHandler {
    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository

    init(pokemonRepository: PokemonRepository, catchRepository: CatchRepository) {
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
    }

    func handle(_ query: GetPokedexQuery) -> Pokedex {
        let allPokemon = pokemonRepository.getAll()
        guard let range = PokedexRegions.getNumbers(inRegion: query.region)?.clamped(to: allPokemon.indices) else {
            return Pokedex(entries: [])
        }
        let catchCounts = CatchRules.countByNumber(catchRepository.getAll().filter { !$0.isFailed })
        let entries = allPokemon[range].map { pokemon in
            PokedexEntry(number: pokemon.number, name: pokemon.name, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, catchCount: catchCounts[pokemon.number] ?? 0)
        }
        return Pokedex(entries: entries)
    }
}
