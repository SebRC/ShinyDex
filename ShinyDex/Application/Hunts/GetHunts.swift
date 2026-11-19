import Foundation

struct GetHuntsQuery {}

final class GetHuntsHandler {
    private let huntRepository: HuntRepository
    private let pokemonRepository: PokemonRepository

    init(huntRepository: HuntRepository, pokemonRepository: PokemonRepository) {
        self.huntRepository = huntRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetHuntsQuery) -> [HuntSummary] {
        let allPokemon = pokemonRepository.getAll()
        return huntRepository.getAll()
            .sorted { $0.priority < $1.priority }
            .map { hunt in
                let members = hunt.indexes
                    .compactMap { allPokemon[safe: $0] }
                    .sorted { $0.number < $1.number }
                    .map { HuntMember(number: $0.number, name: $0.name, encounters: $0.encounters, increment: $0.increment) }
                return HuntSummary(id: HuntID(rawValue: hunt.id), name: hunt.name, priority: hunt.priority, isCollapsed: hunt.isCollapsed, members: members)
            }
    }
}
