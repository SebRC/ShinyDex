import Foundation

struct AddPokemonToHuntCommand {
    let huntId: HuntID
    let number: Int
}

final class AddPokemonToHuntHandler {
    private let huntRepository: HuntRepository
    private let pokemonRepository: PokemonRepository

    init(huntRepository: HuntRepository, pokemonRepository: PokemonRepository) {
        self.huntRepository = huntRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: AddPokemonToHuntCommand) {
        guard let hunt = huntRepository.getAll().first(where: { $0.id == command.huntId.rawValue }),
              let pokemon = pokemonRepository.get(number: command.number) else { return }
        hunt.indexes.append(command.number)
        pokemon.isBeingHunted = true
        pokemonRepository.save(pokemon)
        huntRepository.save(hunt)
    }
}
