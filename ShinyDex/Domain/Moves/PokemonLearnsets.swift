import Foundation

struct LearnableMove: Equatable {
    let id: Int
    let name: String
    let type: String
    let pp: Int
}

enum MoveLearnMethod: Int, CaseIterable {
    case levelUp
    case machine
    case egg
    case tutor
}

struct Learnset: Equatable {
    let movesByMethod: [MoveLearnMethod: [LearnableMove]]

    func contains(_ moveId: Int) -> Bool {
        return movesByMethod.values.contains { $0.contains { $0.id == moveId } }
    }
}

struct PokemonLearnsets {
    struct Key: Hashable {
        let number: Int
        let formId: String?
    }

    fileprivate let movesById: [Int: LearnableMove]
    fileprivate let learnsets: [[[Int]]]
    fileprivate let learnsetIndexesByKey: [Key: [Games: Int]]

    init(movesById: [Int: LearnableMove] = [:], learnsets: [[[Int]]] = [], learnsetIndexesByKey: [Key: [Games: Int]] = [:]) {
        self.movesById = movesById
        self.learnsets = learnsets
        self.learnsetIndexesByKey = learnsetIndexesByKey
    }

    func findMove(_ moveId: Int) -> LearnableMove? {
        return movesById[moveId]
    }

    func findLearnset(of number: Int, formId: String?, in game: Games) -> Learnset? {
        let indexes = learnsetIndexesByKey[Key(number: number, formId: formId)] ?? learnsetIndexesByKey[Key(number: number, formId: nil)]
        guard let index = indexes?[game], learnsets.indices.contains(index) else { return nil }
        var movesByMethod = [MoveLearnMethod: [LearnableMove]]()
        for (methodIndex, moveIds) in learnsets[index].enumerated() {
            guard let method = MoveLearnMethod(rawValue: methodIndex) else { continue }
            let moves = moveIds.compactMap { movesById[$0] }.sorted { $0.name < $1.name }
            if !moves.isEmpty {
                movesByMethod[method] = moves
            }
        }
        return Learnset(movesByMethod: movesByMethod)
    }
}
