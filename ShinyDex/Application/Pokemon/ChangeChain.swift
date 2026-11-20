import Foundation

struct ChangeChainCommand {
    enum Change: Equatable {
        case increment
        case decrement
        case breakChain
        case set(Int)
    }

    let number: Int
    let change: Change
}

final class ChangeChainHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService

    init(pokemonRepository: PokemonRepository, odds: OddsService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
    }

    func handle(_ command: ChangeChainCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        switch command.change {
        case .increment:
            pokemon.chain += 1
        case .decrement:
            guard pokemon.chain > 0 else { return }
            pokemon.chain -= 1
        case .breakChain:
            pokemon.chain = 0
        case .set(let chain):
            pokemon.chain = max(chain, 0)
        }
        pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
        pokemonRepository.save(pokemon)
    }
}
