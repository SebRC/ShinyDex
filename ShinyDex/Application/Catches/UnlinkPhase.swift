import Foundation

struct UnlinkPhaseCommand {
    let huntedNumber: Int
    let catchId: CatchID
}

final class UnlinkPhaseHandler {
    private let pokemonRepository: PokemonRepository

    init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: UnlinkPhaseCommand) {
        guard let hunted = pokemonRepository.get(number: command.huntedNumber) else { return }
        hunted.phases.removeAll { $0.catchId == command.catchId.rawValue }
        pokemonRepository.save(hunted)
    }
}
