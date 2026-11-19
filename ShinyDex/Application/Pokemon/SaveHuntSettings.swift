import Foundation

struct SaveHuntSettingsCommand {
    let number: Int
    let settings: HuntSettings
}

final class SaveHuntSettingsHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService

    init(pokemonRepository: PokemonRepository, odds: OddsService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
    }

    func handle(_ command: SaveHuntSettingsCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        pokemon.huntConfiguration = command.settings.configuration.normalized()
        pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
        pokemonRepository.save(pokemon)
    }
}
