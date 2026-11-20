import Foundation

struct BingoCellDetails: Equatable {
    let index: Int
    let number: Int?
    let pokemonName: String?
    let linkedCatch: CatchSummary?
    let linkableCatchCount: Int
    let isInCompletedLine: Bool
    let formId: String?
    let formName: String?

    var isFilled: Bool {
        return number != nil
    }

    var isObtained: Bool {
        return linkedCatch != nil
    }
}

struct BingoBoardDetails: Equatable {
    let id: BingoBoardID
    let name: String
    let size: BingoBoardSize
    let cells: [BingoCellDetails]
    let completedLineCount: Int

    var filledCount: Int {
        return cells.filter { $0.isFilled }.count
    }

    var obtainedCount: Int {
        return cells.filter { $0.isObtained }.count
    }

    var emptyCount: Int {
        return cells.count - filledCount
    }

    var isBlackout: Bool {
        return obtainedCount == cells.count
    }
}

struct BingoBoardSummary: Equatable {
    let id: BingoBoardID
    let name: String
    let size: BingoBoardSize
    let filledCount: Int
    let obtainedCount: Int
    let completedLineCount: Int

    var isBlackout: Bool {
        return obtainedCount == size.cellCount
    }
}

struct BingoCatchLinks {
    let catches: [Catch]
    let catchesById: [UUID: Catch]
    let evolutions: Evolutions

    init(catches: [Catch], evolutions: Evolutions) {
        self.catches = catches
        catchesById = Dictionary(catches.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.evolutions = evolutions
    }

    func findLinkableCatches(at index: Int, in board: BingoBoard) -> [Catch] {
        guard board.cells.indices.contains(index), let number = board.cells[index].number else { return [] }
        let linkedId = board.cells[index].catchId
        let formId = board.cells[index].formId
        let line = Set(evolutions.getLine(of: number)).union([number])
        return catches
            .filter { !$0.isFailed && line.contains($0.number) && $0.matchesForm(formId) && (!board.isLinked($0) || $0.id == linkedId) }
            .sorted { ($0.number == number ? 0 : 1, $0.caughtDate ?? .distantPast) < ($1.number == number ? 0 : 1, $1.caughtDate ?? .distantPast) }
    }
}

extension BingoBoardRepository {
    func find(_ id: BingoBoardID) -> BingoBoard? {
        return getAll().first { $0.id == id.rawValue }
    }
}
