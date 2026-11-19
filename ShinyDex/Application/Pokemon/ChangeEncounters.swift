import Foundation

struct ChangeEncountersCommand {
    enum Change: Equatable {
        case increment
        case decrement
        case set(Int)
    }

    let number: Int
    let change: Change
}

final class ChangeEncountersHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService

    init(pokemonRepository: PokemonRepository, odds: OddsService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
    }

    func handle(_ command: ChangeEncountersCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        switch command.change {
        case .increment:
            pokemon.encounters += pokemon.increment
        case .decrement:
            guard pokemon.encounters > 0 else { return }
            pokemon.encounters -= 1
        case .set(let encounters):
            pokemon.encounters = max(encounters, 0)
        }
        pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
        pokemonRepository.save(pokemon)
    }
}
