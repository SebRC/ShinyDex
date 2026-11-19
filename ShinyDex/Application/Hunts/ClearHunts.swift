import Foundation

struct ClearHuntsCommand {}

final class ClearHuntsHandler {
    private let huntRepository: HuntRepository
    private let pokemonRepository: PokemonRepository

    init(huntRepository: HuntRepository, pokemonRepository: PokemonRepository) {
        self.huntRepository = huntRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: ClearHuntsCommand) {
        let huntedNumbers = Set(huntRepository.getAll().flatMap { $0.indexes })
        huntRepository.clear()
        for number in huntedNumbers {
            guard let pokemon = pokemonRepository.get(number: number) else { continue }
            pokemon.isBeingHunted = false
            pokemonRepository.save(pokemon)
        }
    }
}
