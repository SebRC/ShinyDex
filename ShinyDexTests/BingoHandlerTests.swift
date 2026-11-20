import XCTest
@testable import ShinyDex

final class BingoHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var boards: InMemoryBingoBoardRepository!
    private let evolutions = Evolutions(evolvesFrom: [-1, 0, 1, -1])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"])
        catches = InMemoryCatchRepository()
        boards = InMemoryBingoBoardRepository()
    }

    private func create(_ size: BingoBoardSize = .three, numbers: [Int] = [0, 1, 2]) -> BingoBoardID {
        return CreateBingoBoardHandler(bingoBoardRepository: boards).handle(CreateBingoBoardCommand(name: "Bingo", size: size, pokemonNumbers: numbers))
    }

    private func update(_ id: BingoBoardID, _ change: UpdateBingoBoardCommand.Change) {
        UpdateBingoBoardHandler(bingoBoardRepository: boards).handle(UpdateBingoBoardCommand(boardId: id, change: change))
    }

    private func getDetails(_ id: BingoBoardID) -> BingoBoardDetails? {
        return GetBingoBoardDetailsHandler(bingoBoardRepository: boards, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions)
            .handle(GetBingoBoardDetailsQuery(boardId: id))
    }

    private func getSummaries() -> [BingoBoardSummary] {
        return GetBingoBoardsHandler(bingoBoardRepository: boards, catchRepository: catches).handle(GetBingoBoardsQuery())
    }

    private func getLinkable(_ id: BingoBoardID, at index: Int) -> [CatchID] {
        return GetLinkableBingoCatchesHandler(bingoBoardRepository: boards, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions)
            .handle(GetLinkableBingoCatchesQuery(boardId: id, cellIndex: index))
            .map { $0.id }
    }

    private func logCatch(_ number: Int, isFailed: Bool = false) -> CatchID {
        let caught = Catch(pokemon: pokemon.get(number: number)!, caughtBall: isFailed ? CatchRules.noBall : "poke", caughtDate: Date(), isFailed: isFailed)
        catches.insert(caught)
        catches.save()
        return CatchID(rawValue: caught.id)
    }

    func test_createdBoard_showsPokemonNamesInTheirSquares() throws {
        let id = create(.four, numbers: [3, 0])

        let details = try XCTUnwrap(getDetails(id))

        XCTAssertEqual(details.size, .four)
        XCTAssertEqual(details.cells.count, 16)
        XCTAssertEqual(details.cells.prefix(3).map { $0.pokemonName }, ["Charmander", "Bulbasaur", nil])
        XCTAssertEqual(details.emptyCount, 14)
    }

    func test_newBoards_areListedInCreationOrder() {
        _ = create()
        let second = create(.five)

        let summaries = getSummaries()

        XCTAssertEqual(summaries.map { $0.size }, [.three, .five])
        XCTAssertEqual(summaries.last?.id, second)
    }

    func test_linkableCatches_comeFromTheEvolutionLine_andSkipFailedAndAlreadyLinked() {
        let id = create(numbers: [0, 0, 3])
        let ivysaur = logCatch(1)
        let bulbasaur = logCatch(0)
        _ = logCatch(0, isFailed: true)
        _ = logCatch(3)

        XCTAssertEqual(getLinkable(id, at: 0), [bulbasaur, ivysaur], "The square's own species comes first")
        update(id, .link(at: 0, catchId: bulbasaur))

        XCTAssertEqual(getLinkable(id, at: 0), [bulbasaur, ivysaur], "The square's current catch stays pickable")
        XCTAssertEqual(getLinkable(id, at: 1), [ivysaur], "A catch links to one square per board")
        XCTAssertEqual(getDetails(id)?.cells[1].linkableCatchCount, 1)
        XCTAssertTrue(getLinkable(id, at: 4).isEmpty, "Empty squares have nothing to link")
    }

    func test_linkingCatchesAcrossARow_completesALine_andHighlightsItsSquares() throws {
        let id = create()
        for index in 0..<3 {
            update(id, .link(at: index, catchId: logCatch(index)))
        }

        let details = try XCTUnwrap(getDetails(id))
        let summary = try XCTUnwrap(getSummaries().first)

        XCTAssertEqual(details.cells[0].linkedCatch?.pokemonName, "Bulbasaur")
        XCTAssertEqual(details.completedLineCount, 1)
        XCTAssertEqual(details.cells.map { $0.isInCompletedLine }, [true, true, true, false, false, false, false, false, false])
        XCTAssertEqual(summary.obtainedCount, 3)
        XCTAssertEqual(summary.completedLineCount, 1)
    }

    func test_unlinkingACatch_clearsTheSquare() throws {
        let id = create()
        update(id, .link(at: 0, catchId: logCatch(0)))

        update(id, .link(at: 0, catchId: nil))

        XCTAssertNil(try XCTUnwrap(getDetails(id)).cells[0].linkedCatch)
    }

    func test_placeClearAndSwap_changeTheChosenSquares() throws {
        let id = create(numbers: [0])

        update(id, .place(number: 3, at: 8))
        update(id, .swap(0, 4))
        update(id, .clear(at: 8))

        let numbers = try XCTUnwrap(getDetails(id)).cells.map { $0.number }
        XCTAssertEqual(numbers, [nil, nil, nil, nil, 0, nil, nil, nil, nil])
    }

    func test_shuffle_keepsThePickedPokemonAndTheirCatchesOnTheBoard() throws {
        let id = create(.five, numbers: [0, 1, 2, 3])
        let catchId = logCatch(2)
        update(id, .link(at: 2, catchId: catchId))

        update(id, .shuffle)

        let cells = try XCTUnwrap(getDetails(id)).cells
        XCTAssertEqual(cells.compactMap { $0.number }.sorted(), [0, 1, 2, 3])
        XCTAssertEqual(cells.first { $0.number == 2 }?.linkedCatch?.id, catchId)
    }

    func test_fillEmptyCells_and_rename_areSaved() throws {
        let id = create(numbers: [0])

        update(id, .fillEmptyCells([1, 2]))
        update(id, .rename("Grass starters"))

        let details = try XCTUnwrap(getDetails(id))
        XCTAssertEqual(details.name, "Grass starters")
        XCTAssertEqual(details.cells.prefix(4).map { $0.number }, [0, 1, 2, nil])
    }

    func test_delete_removesTheBoard() {
        let id = create()

        DeleteBingoBoardHandler(bingoBoardRepository: boards).handle(DeleteBingoBoardCommand(boardId: id))

        XCTAssertNil(getDetails(id))
    }
}
