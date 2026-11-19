import Foundation

struct DeleteCatchCommand {
    let catchId: CatchID
}

final class DeleteCatchHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: DeleteCatchCommand) {
        guard let caught = catchRepository.get(id: command.catchId.rawValue) else { return }
        catchRepository.delete(caught)
        if catchRepository.save() {
            CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: caught.number)
        }
    }
}
