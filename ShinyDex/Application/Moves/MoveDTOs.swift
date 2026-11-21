import Foundation

struct MoveSlot: Equatable {
    var name: String
    var maxPP: Int
    var remainingPP: Int
    var type: String
}

struct ActiveMoveSet: Equatable {
    var slots: [MoveSlot]
    var pressureActive: Bool
}

struct MoveOption: Equatable {
    let identifier: String
    let name: String
    let pp: Int
    let type: String
}

extension MoveSlot {
    init(_ move: ActiveMove) {
        self.init(name: move.name, maxPP: move.maxPP, remainingPP: move.remainingPP, type: move.type)
    }

    var isPlaceholder: Bool {
        return activeMove.isPlaceholder
    }

    var activeMove: ActiveMove {
        return ActiveMove(name: name, maxPP: maxPP, remainingPP: remainingPP, type: type)
    }
}
