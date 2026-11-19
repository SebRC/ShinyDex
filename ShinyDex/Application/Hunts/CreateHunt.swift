import Foundation

struct CreateHuntCommand {
    let name: String
    let pokemonNumbers: [Int]
}

final class CreateHuntHandler {
    private let huntRepository: HuntRepository
    private let pokemonRepository: PokemonRepository

    init(huntRepository: HuntRepository, pokemonRepository: PokemonRepository) {
        self.huntRepository = huntRepository
        self.pokemonRepository = pokemonRepository
    }

    @discardableResult
    func handle(_ command: CreateHuntCommand) -> HuntID {
        let priority = (huntRepository.getAll().map { $0.priority }.max() ?? -1) + 1
        let hunt = Hunt(name: command.name, indexes: [], priority: priority, isCollapsed: false)
        for number in command.pokemonNumbers.sorted() {
            guard let pokemon = pokemonRepository.get(number: number) else { continue }
            hunt.indexes.append(number)
            pokemon.isBeingHunted = true
            pokemonRepository.save(pokemon)
        }
        huntRepository.save(hunt)
        return HuntID(rawValue: hunt.id)
    }
}
