import XCTest
@testable import ShinyDex

final class BingoBoardTests: XCTestCase {
    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64

        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }

    private var catchesById = [UUID: Catch]()

    override func setUp() {
        catchesById = [:]
    }

    @discardableResult
    private func linkNewCatch(on board: BingoBoard, at index: Int, isFailed: Bool = false) -> UUID {
        let caught = Catch(number: board.cells[index].number ?? 0, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: Date(), isFailed: isFailed)
        catchesById[caught.id] = caught
        board.link(caught.id, at: index)
        return caught.id
    }

    func test_newBoard_hasOneCellPerSquare_andFillsPickedPokemonInOrder() {
        for size in BingoBoardSize.allCases {
            let board = BingoBoard(name: "Bingo", priority: 0, size: size, numbers: [4, 7])

            XCTAssertEqual(board.cells.count, size.rawValue * size.rawValue)
            XCTAssertEqual(board.cells.prefix(3).map { $0.number }, [4, 7, nil])
            XCTAssertEqual(board.filledCount, 2)
        }
    }

    func test_newBoard_ignoresPicksBeyondItsSquares() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: Array(0..<12))

        XCTAssertEqual(board.cells.compactMap { $0.number }, Array(0..<9))
    }

    func test_place_putsPokemonInTheChosenSquare_withoutALinkedCatch() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [1])
        linkNewCatch(on: board, at: 0)

        board.place(25, at: 4)
        board.place(26, at: 0)
        board.place(27, at: 9)

        XCTAssertEqual(board.cells[4], BingoCell(number: 25, catchId: nil))
        XCTAssertEqual(board.cells[0], BingoCell(number: 26, catchId: nil), "Replacing a Pokémon unlinks its catch")
        XCTAssertEqual(board.filledCount, 2, "Out of range squares are ignored")
    }

    func test_link_onlyLinksFilledSquares_andEachCatchOnce() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [1, 1])
        let catchId = linkNewCatch(on: board, at: 0)

        XCTAssertFalse(board.link(catchId, at: 1), "A catch already on the board can't be linked again")
        XCTAssertFalse(board.link(UUID(), at: 5), "Empty squares can't be linked")
        XCTAssertTrue(board.link(catchId, at: 0), "Relinking the same square is allowed")
        XCTAssertEqual(board.cells.compactMap { $0.catchId }, [catchId])
    }

    func test_countObtained_ignoresUnlinkedMissingAndFailedCatches() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [1, 2, 3, 4])
        linkNewCatch(on: board, at: 0)
        linkNewCatch(on: board, at: 1, isFailed: true)
        board.link(UUID(), at: 2)

        XCTAssertEqual(board.countObtained(in: catchesById), 1)
        XCTAssertNotNil(board.findLinkedCatch(at: 0, in: catchesById))
        XCTAssertNil(board.findLinkedCatch(at: 1, in: catchesById))
        XCTAssertNil(board.findLinkedCatch(at: 2, in: catchesById))
    }

    func test_swap_movesPokemonWithTheirLinkedCatch() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [1, 2])
        let catchId = linkNewCatch(on: board, at: 0)

        board.swap(0, 8)

        XCTAssertEqual(board.cells[8], BingoCell(number: 1, catchId: catchId))
        XCTAssertEqual(board.cells[0], .empty)
    }

    func test_fillEmptyCells_skipsFilledSquares() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [1])
        board.swap(0, 1)

        board.fillEmptyCells(with: [5, 6])

        XCTAssertEqual(board.cells.prefix(4).map { $0.number }, [5, 1, 6, nil])
    }

    func test_shuffle_keepsEveryPokemonAndItsLinkedCatch_inNewSquares() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .five, numbers: Array(0..<10))
        let catchId = linkNewCatch(on: board, at: 3)
        let before = board.cells
        var generator = SeededGenerator(state: 42)

        board.shuffle(using: &generator)

        XCTAssertNotEqual(board.cells, before)
        XCTAssertEqual(board.cells.compactMap { $0.number }.sorted(), Array(0..<10))
        XCTAssertEqual(board.cells.first { $0.number == 3 }?.catchId, catchId)
    }

    func test_findCompletedLines_countsRowsColumnsAndDiagonals() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: Array(0..<9))
        for index in [0, 1, 2, 4, 8] {
            linkNewCatch(on: board, at: index)
        }

        XCTAssertEqual(Set(board.findCompletedLines(in: catchesById)), [[0, 1, 2], [0, 4, 8]])
    }

    func test_findCompletedLines_needsEverySquareCaught() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .three, numbers: [0, 1])
        linkNewCatch(on: board, at: 0)
        linkNewCatch(on: board, at: 1)

        XCTAssertTrue(board.findCompletedLines(in: catchesById).isEmpty)
    }

    func test_findCompletedLines_onAFullFourByFourBoard_findsAllTenLines() {
        let board = BingoBoard(name: "Bingo", priority: 0, size: .four, numbers: Array(0..<16))
        for index in 0..<16 {
            linkNewCatch(on: board, at: index)
        }

        XCTAssertEqual(board.findCompletedLines(in: catchesById).count, 10)
    }

    func test_restoringStoredCells_fitsThemToTheBoardSize() {
        let catchId = UUID()
        let tooFew = BingoBoard(id: UUID(), name: "Bingo", createdDate: Date(), priority: 0, size: .three, cells: [BingoCell(number: 1, catchId: catchId)])
        let tooMany = BingoBoard(id: UUID(), name: "Bingo", createdDate: Date(), priority: 0, size: .three, cells: Array(repeating: BingoCell(number: 1, catchId: nil), count: 12))

        XCTAssertEqual(tooFew.cells.count, 9)
        XCTAssertEqual(tooFew.cells[0], BingoCell(number: 1, catchId: catchId))
        XCTAssertEqual(tooMany.cells.count, 9)
    }
}
