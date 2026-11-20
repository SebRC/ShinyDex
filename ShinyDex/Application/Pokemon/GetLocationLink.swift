import Foundation

struct GetLocationLinkQuery {
    let number: Int
}

final class GetLocationLinkHandler {
    private let pokemonRepository: PokemonRepository
    private let locationLinkProvider: LocationLinkProvider

    init(pokemonRepository: PokemonRepository, locationLinkProvider: LocationLinkProvider) {
        self.pokemonRepository = pokemonRepository
        self.locationLinkProvider = locationLinkProvider
    }

    func handle(_ query: GetLocationLinkQuery) -> URL? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        return URL(string: locationLinkProvider.makeLocationURL(forPokemonNamed: pokemon.name, number: pokemon.number, generation: pokemon.generation))
    }
}
