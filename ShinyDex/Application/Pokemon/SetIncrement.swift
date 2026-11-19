import Foundation

struct SetIncrementCommand {
    let number: Int
    let increment: Int
}

final class SetIncrementHandler {
    private let pokemonRepository: PokemonRepository

    init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: SetIncrementCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        pokemon.increment = command.increment
        pokemonRepository.save(pokemon)
    }
}
