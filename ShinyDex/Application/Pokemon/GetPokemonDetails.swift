import Foundation

struct GetPokemonDetailsQuery {
    let number: Int
}

final class GetPokemonDetailsHandler {
    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let mapper: PokemonDetailsMapper

    init(pokemonRepository: PokemonRepository, catchRepository: CatchRepository, odds: OddsService, probability: ProbabilityService) {
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        mapper = PokemonDetailsMapper(odds: odds, probability: probability)
    }

    func handle(_ query: GetPokemonDetailsQuery) -> PokemonDetails? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        let catchCount = catchRepository.getAll(number: query.number).filter { !$0.isFailed }.count
        return mapper.makeDetails(of: pokemon, catchCount: catchCount)
    }
}
