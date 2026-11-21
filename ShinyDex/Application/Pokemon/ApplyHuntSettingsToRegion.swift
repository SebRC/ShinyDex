import Foundation

struct ApplyHuntSettingsToRegionCommand {
    let settings: HuntSettings
    let region: Int
}

final class ApplyHuntSettingsToRegionHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService

    init(pokemonRepository: PokemonRepository, odds: OddsService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
    }

    func handle(_ command: ApplyHuntSettingsToRegionCommand) {
        guard let numbers = PokedexRegions.getNumbers(inRegion: command.region) else { return }
        let configuration = command.settings.configuration.normalized()
        for pokemon in pokemonRepository.getAll() where numbers.contains(pokemon.number) {
            pokemon.huntConfiguration = configuration
            pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
            pokemonRepository.save(pokemon)
        }
    }
}
