import Foundation

enum PokedexFilter: CaseIterable {
    case all
    case notCaught
    case caught
    case inHunt
}

struct GetPokedexQuery {
    let region: Int
    var filter = PokedexFilter.all
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
    let caughtCount: Int
    let totalCount: Int

    static let empty = Pokedex(entries: [], caughtCount: 0, totalCount: 0)
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
            return .empty
        }
        let catchCounts = CatchRules.countByNumber(catchRepository.getAll().filter { !$0.isFailed })
        let regionEntries = allPokemon[range].map { pokemon in
            PokedexEntry(number: pokemon.number, name: pokemon.name, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, catchCount: catchCounts[pokemon.number] ?? 0)
        }
        return Pokedex(entries: regionEntries.filter { GetPokedexHandler.matches($0, query.filter) },
                       caughtCount: regionEntries.filter { $0.catchCount > 0 }.count,
                       totalCount: regionEntries.count)
    }

    private static func matches(_ entry: PokedexEntry, _ filter: PokedexFilter) -> Bool {
        switch filter {
        case .all: return true
        case .notCaught: return entry.catchCount == 0
        case .caught: return entry.catchCount > 0
        case .inHunt: return entry.isBeingHunted
        }
    }
}
