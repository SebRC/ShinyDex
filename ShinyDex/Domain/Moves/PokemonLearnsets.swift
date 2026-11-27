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

struct GenerationLearnset: Equatable {
    struct Entry: Equatable {
        let move: LearnableMove
        let number: Int
        let game: Games
    }

    let entriesByMethod: [MoveLearnMethod: [Entry]]
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

    func findGenerationLearnset(of number: Int, formId: String?, caughtIn game: Games, evolutions: Evolutions) -> GenerationLearnset? {
        let generation = GamesList.games[game]?.generation
        let generationGames = [game] + Games.allCases.filter { $0 != game && generation != nil && GamesList.games[$0]?.generation == generation }
        let lineage = PokemonLearnsets.makeLineage(of: number, evolutions: evolutions)
        let sources = lineage.flatMap { species in generationGames.map { (species, $0) } }
        var hasData = false
        var seenMoveIds = Set<Int>()
        var entriesByMethod = [MoveLearnMethod: [GenerationLearnset.Entry]]()
        for (index, (species, sourceGame)) in sources.enumerated() {
            guard let learnset = findLearnset(of: species, formId: formId, in: sourceGame) else { continue }
            hasData = true
            let isNative = index == 0
            var addedMoveIds = Set<Int>()
            for method in MoveLearnMethod.allCases {
                for move in learnset.movesByMethod[method] ?? [] where isNative || !seenMoveIds.contains(move.id) {
                    guard isNative || !addedMoveIds.contains(move.id) else { continue }
                    entriesByMethod[method, default: []].append(GenerationLearnset.Entry(move: move, number: species, game: sourceGame))
                    addedMoveIds.insert(move.id)
                }
            }
            seenMoveIds.formUnion(addedMoveIds)
        }
        guard hasData else { return nil }
        let findSortRank = { (entry: GenerationLearnset.Entry) in entry.number == number && entry.game == game ? 0 : 1 }
        return GenerationLearnset(entriesByMethod: entriesByMethod.mapValues { entries in
            entries.sorted { (findSortRank($0), $0.move.name) < (findSortRank($1), $1.move.name) }
        })
    }

    fileprivate static func makeLineage(of number: Int, evolutions: Evolutions) -> [Int] {
        var lineage = [number]
        while let parent = evolutions.getParent(of: lineage.last!), !lineage.contains(parent) {
            lineage.append(parent)
        }
        return lineage
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
