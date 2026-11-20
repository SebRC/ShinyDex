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
    let isRegion: Bool

    var caughtCount: Int {
        return entries.filter { $0.catchCount > 0 }.count
    }
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
        let catchCounts = CatchRules.countByNumber(catchRepository.getAll().filter { !$0.isFailed })
        let range = PokedexRegions.getNumbers(inRegion: query.region)
        let listed: [Pokemon]
        if let range = range, range.upperBound <= allPokemon.count {
            listed = Array(allPokemon[range])
        } else {
            listed = allPokemon.filter { $0.caughtBall != "none" }
        }
        let entries = listed.map { pokemon in
            PokedexEntry(number: pokemon.number, name: pokemon.name, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, catchCount: catchCounts[pokemon.number] ?? 0)
        }
        return Pokedex(entries: entries, isRegion: range != nil)
    }
}
