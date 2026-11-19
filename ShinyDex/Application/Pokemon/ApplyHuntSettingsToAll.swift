import Foundation

struct ApplyHuntSettingsToAllCommand {
    let settings: HuntSettings
}

final class ApplyHuntSettingsToAllHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService

    init(pokemonRepository: PokemonRepository, odds: OddsService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
    }

    func handle(_ command: ApplyHuntSettingsToAllCommand) {
        let configuration = command.settings.configuration.normalized()
        for pokemon in pokemonRepository.getAll() {
            pokemon.huntConfiguration = configuration
            pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
            pokemonRepository.save(pokemon)
        }
    }
}
