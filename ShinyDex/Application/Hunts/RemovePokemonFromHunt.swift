import Foundation

struct RemovePokemonFromHuntCommand {
    let huntId: HuntID
    let number: Int
}

final class RemovePokemonFromHuntHandler {
    private let huntRepository: HuntRepository
    private let pokemonRepository: PokemonRepository

    init(huntRepository: HuntRepository, pokemonRepository: PokemonRepository) {
        self.huntRepository = huntRepository
        self.pokemonRepository = pokemonRepository
    }

    // Removing the last Pokémon removes the hunt, and the remaining hunts are renumbered so priorities stay contiguous.
    func handle(_ command: RemovePokemonFromHuntCommand) {
        let hunts = huntRepository.getAll()
        guard let hunt = hunts.first(where: { $0.id == command.huntId.rawValue }) else { return }
        if let pokemon = pokemonRepository.get(number: command.number) {
            pokemon.isBeingHunted = false
            pokemonRepository.save(pokemon)
        }
        hunt.indexes.removeAll { $0 == command.number }
        guard hunt.indexes.isEmpty else {
            huntRepository.save(hunt)
            return
        }
        huntRepository.delete(hunt)
        let remaining = hunts.filter { $0.id != hunt.id }.sorted { $0.priority < $1.priority }
        for (priority, remainingHunt) in remaining.enumerated() {
            remainingHunt.priority = priority
            huntRepository.save(remainingHunt)
        }
    }
}
