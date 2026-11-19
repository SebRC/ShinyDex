import Foundation

// Keeps a Pokémon's shown ball and caught state in line with its catches after they change.
struct CaughtBallSync {
    let catchRepository: CatchRepository
    let pokemonRepository: PokemonRepository

    func sync(number: Int) {
        guard let pokemon = pokemonRepository.get(number: number) else { return }
        let catches = catchRepository.getAll(number: number).filter { !$0.isFailed }
        pokemon.caughtBall = CatchRules.latestBall(of: catches)
        pokemon.caughtDescription = catches.isEmpty ? "Not Caught" : "Caught"
        pokemonRepository.save(pokemon)
    }
}
