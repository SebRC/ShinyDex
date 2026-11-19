import Foundation

struct SaveActiveMovesCommand {
    let moves: ActiveMoveSet
}

final class SaveActiveMovesHandler {
    private let moveRepository: MoveRepository

    init(moveRepository: MoveRepository) {
        self.moveRepository = moveRepository
    }

    func handle(_ command: SaveActiveMovesCommand) {
        moveRepository.save(ActiveMoves(moves: command.moves.slots.map { $0.activeMove }, pressureActive: command.moves.pressureActive))
    }
}
