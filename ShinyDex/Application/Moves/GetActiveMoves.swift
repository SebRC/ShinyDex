import Foundation

struct GetActiveMovesQuery {}

final class GetActiveMovesHandler {
    private let moveRepository: MoveRepository

    init(moveRepository: MoveRepository) {
        self.moveRepository = moveRepository
    }

    func handle(_ query: GetActiveMovesQuery) -> ActiveMoveSet {
        guard let activeMoves = moveRepository.getActiveMoves() else {
            return ActiveMoveSet(slots: [], pressureActive: false)
        }
        return ActiveMoveSet(slots: activeMoves.moves.map(MoveSlot.init), pressureActive: activeMoves.pressureActive)
    }
}
