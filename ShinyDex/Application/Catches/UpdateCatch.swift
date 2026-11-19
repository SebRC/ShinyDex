import Foundation

enum CatchUpdateError: Error, Equatable {
    case notFound
    case saveFailed
}

struct UpdateCatchCommand {
    enum Change: Equatable {
        case ball(String)
        case game(Games)
        case huntMethod(HuntMethod)
        case encounters(Int)
        case caughtDate(Date?)
        case evs(EffortValues)
        case nickname(String?)
        case gender(Gender?)
        case nature(Nature?)
        case ivs(IndividualValues)
    }

    let catchId: CatchID
    let change: Change
}

final class UpdateCatchHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: UpdateCatchCommand) throws {
        guard let caught = catchRepository.get(id: command.catchId.rawValue) else { throw CatchUpdateError.notFound }
        switch command.change {
        case .ball(let ball): caught.caughtBall = ball
        case .game(let game): caught.game = game
        case .huntMethod(let method): caught.huntMethod = method
        case .encounters(let encounters): caught.encounters = encounters
        case .caughtDate(let date): caught.caughtDate = date
        case .evs(let evs): caught.evs = evs
        case .nickname(let nickname): caught.nickname = nickname
        case .gender(let gender): caught.gender = gender
        case .nature(let nature): caught.nature = nature
        case .ivs(let ivs): caught.ivs = ivs
        }
        catchRepository.update(caught)
        guard catchRepository.save() else { throw CatchUpdateError.saveFailed }
        CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: caught.number)
    }
}
