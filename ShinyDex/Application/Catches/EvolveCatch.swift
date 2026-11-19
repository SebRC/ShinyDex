import Foundation

struct EvolveCatchCommand {
    let catchId: CatchID
    let targetNumber: Int
}

final class EvolveCatchHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: EvolveCatchCommand) throws {
        guard let caught = catchRepository.get(id: command.catchId.rawValue) else { throw CatchUpdateError.notFound }
        let previousNumber = caught.number
        let originalNumber = caught.evolvedFrom ?? caught.number
        caught.number = command.targetNumber
        caught.evolvedFrom = originalNumber == command.targetNumber ? nil : originalNumber
        catchRepository.update(caught)
        guard catchRepository.save() else { throw CatchUpdateError.saveFailed }
        let sync = CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository)
        sync.sync(number: previousNumber)
        sync.sync(number: command.targetNumber)
    }
}
