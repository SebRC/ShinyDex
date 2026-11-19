import Foundation

class ActiveMoves {
    var moves: [ActiveMove]
    var pressureActive: Bool

    init(moves: [ActiveMove], pressureActive: Bool) {
        self.moves = moves
        self.pressureActive = pressureActive
    }
}
