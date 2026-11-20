import Foundation

struct CaughtBallSync {
    let catchRepository: CatchRepository
    let pokemonRepository: PokemonRepository

    func sync(number: Int) {
        guard let pokemon = pokemonRepository.get(number: number) else { return }
        let catches = catchRepository.getAll(number: number).filter { !$0.isFailed }
        pokemon.caughtBall = CatchRules.getLatestBall(of: catches)
        pokemon.caughtDescription = catches.isEmpty ? "Not Caught" : "Caught"
        pokemonRepository.save(pokemon)
    }
}
