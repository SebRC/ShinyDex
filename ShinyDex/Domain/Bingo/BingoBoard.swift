import Foundation

enum BingoBoardSize: Int, CaseIterable {
    case three = 3
    case four = 4
    case five = 5

    var cellCount: Int {
        return rawValue * rawValue
    }

    var title: String {
        return "\(rawValue)×\(rawValue)"
    }
}

struct BingoCell: Equatable {
    var number: Int?
    var catchId: UUID?
    var formId: String?

    init(number: Int?, catchId: UUID?, formId: String? = nil) {
        self.number = number
        self.catchId = catchId
        self.formId = formId
    }

    static let empty = BingoCell(number: nil, catchId: nil)

    var isFilled: Bool {
        return number != nil
    }
}

class BingoBoard {
    let id: UUID
    var name: String
    let createdDate: Date
    var priority: Int
    let size: BingoBoardSize
    private(set) var cells: [BingoCell]

    init(name: String, priority: Int, size: BingoBoardSize, numbers: [Int] = []) {
        id = UUID()
        self.name = name
        createdDate = Date()
        self.priority = priority
        self.size = size
        cells = Array(repeating: .empty, count: size.cellCount)
        fillEmptyCells(with: numbers)
    }

    init(id: UUID, name: String, createdDate: Date, priority: Int, size: BingoBoardSize, cells: [BingoCell]) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.priority = priority
        self.size = size
        self.cells = BingoBoard.fitting(cells, to: size)
    }

    var filledCount: Int {
        return cells.filter { $0.isFilled }.count
    }

    var emptyCount: Int {
        return cells.count - filledCount
    }

    func place(_ number: Int, at index: Int) {
        guard cells.indices.contains(index) else { return }
        cells[index] = BingoCell(number: number, catchId: nil)
    }

    func setForm(_ formId: String?, at index: Int) {
        guard cells.indices.contains(index), cells[index].isFilled else { return }
        guard cells[index].formId != formId else { return }
        cells[index].formId = formId
        cells[index].catchId = nil
    }

    func clear(at index: Int) {
        guard cells.indices.contains(index) else { return }
        cells[index] = .empty
    }

    @discardableResult
    func link(_ catchId: UUID?, at index: Int) -> Bool {
        guard cells.indices.contains(index), cells[index].isFilled else { return false }
        if let catchId = catchId, cells.indices.contains(where: { $0 != index && cells[$0].catchId == catchId }) {
            return false
        }
        cells[index].catchId = catchId
        return true
    }

    func isLinked(_ caught: Catch) -> Bool {
        return cells.contains { $0.catchId == caught.id }
    }

    func findLinkedCatch(at index: Int, in catchesById: [UUID: Catch]) -> Catch? {
        guard cells.indices.contains(index), cells[index].isFilled,
              let catchId = cells[index].catchId, let caught = catchesById[catchId], !caught.isFailed, caught.matchesForm(cells[index].formId) else { return nil }
        return caught
    }

    func countObtained(in catchesById: [UUID: Catch]) -> Int {
        return cells.indices.filter { findLinkedCatch(at: $0, in: catchesById) != nil }.count
    }

    func swap(_ first: Int, _ second: Int) {
        guard cells.indices.contains(first), cells.indices.contains(second) else { return }
        cells.swapAt(first, second)
    }

    func fillEmptyCells(with numbers: [Int]) {
        var remaining = numbers[...]
        for index in cells.indices where !cells[index].isFilled {
            guard let number = remaining.popFirst() else { return }
            cells[index] = BingoCell(number: number, catchId: nil)
        }
    }

    func shuffle<Generator: RandomNumberGenerator>(using generator: inout Generator) {
        cells.shuffle(using: &generator)
    }

    func findCompletedLines(in catchesById: [UUID: Catch]) -> [[Int]] {
        return makeLines().filter { line in line.allSatisfy { findLinkedCatch(at: $0, in: catchesById) != nil } }
    }

    private func makeLines() -> [[Int]] {
        let side = size.rawValue
        let positions = Array(0..<side)
        let rows = positions.map { row in positions.map { row * side + $0 } }
        let columns = positions.map { column in positions.map { $0 * side + column } }
        let diagonal = positions.map { $0 * side + $0 }
        let antiDiagonal = positions.map { $0 * side + (side - 1 - $0) }
        return rows + columns + [diagonal, antiDiagonal]
    }

    private static func fitting(_ cells: [BingoCell], to size: BingoBoardSize) -> [BingoCell] {
        let trimmed = Array(cells.prefix(size.cellCount))
        return trimmed + Array(repeating: .empty, count: size.cellCount - trimmed.count)
    }
}
