import XCTest
@testable import ShinyDex

final class BingoTemplateTests: XCTestCase {
    private var names: [String]!
    private var templates: BingoTemplates!
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var boards: InMemoryBingoBoardRepository!

    override func setUp() {
        let loader = BundleResourceLoader(bundle: Bundle(for: AppDelegate.self))
        names = loader.loadLines(ofTextResource: "allGens")
        templates = BingoTemplatesLoader.load(from: loader, pokemonNames: names, forms: PokemonFormsLoader.load(from: loader))
        pokemon = InMemoryPokemonRepository(names: names)
        catches = InMemoryCatchRepository()
        boards = InMemoryBingoBoardRepository()
    }

    private func createBoard(size: BingoBoardSize, source: CreateGeneratedBingoBoardCommand.Source) -> BingoBoard? {
        let id = CreateGeneratedBingoBoardHandler(bingoBoardRepository: boards, pokemonRepository: pokemon, catchRepository: catches, templates: templates)
            .handle(CreateGeneratedBingoBoardCommand(name: "Test", size: size, source: source))
        return id.flatMap { id in boards.getAll().first { $0.id == id.rawValue } }
    }

    // MARK: Bundled templates

    func test_everyBundledTemplate_resolvesAllItsPokemon() {
        let expectedCounts = ["starters": 27, "eeveelutions": 9, "pseudo-legendaries": 10, "fossils": 15, "legendaries": 66, "mythicals": 22,
                              "alolan-forms": 18, "galarian-forms": 19, "hisuian-forms": 16, "unown": 28, "vivillon": 20]

        XCTAssertEqual(Dictionary(uniqueKeysWithValues: templates.templates.map { ($0.id, $0.entries.count) }), expectedCounts)
    }

    func test_formTemplates_carryTheirForm() throws {
        let alolan = try XCTUnwrap(templates.find(id: "alolan-forms"))
        XCTAssertTrue(alolan.entries.allSatisfy { $0.formId == "alola" })
        XCTAssertTrue(alolan.entries.contains(BingoEntry(number: names.firstIndex(of: "Vulpix")!, formId: "alola")))

        let unown = try XCTUnwrap(templates.find(id: "unown"))
        XCTAssertEqual(unown.entries.first, BingoEntry(number: names.firstIndex(of: "Unown")!, formId: nil))
        XCTAssertEqual(Set(unown.entries.map { $0.number }).count, 1)
    }

    // MARK: Generated boards

    func test_templateBoard_fillsEverySquareFromTheTemplate_withoutRepeats() throws {
        let board = try XCTUnwrap(createBoard(size: .five, source: .template(id: "starters")))
        let starters = Set(templates.find(id: "starters")!.entries.map { $0.number })

        let numbers = board.cells.compactMap { $0.number }
        XCTAssertEqual(numbers.count, 25)
        XCTAssertEqual(Set(numbers).count, 25)
        XCTAssertTrue(Set(numbers).isSubset(of: starters))
    }

    func test_templateSmallerThanTheBoard_leavesTheRestEmpty() throws {
        let board = try XCTUnwrap(createBoard(size: .four, source: .template(id: "eeveelutions")))

        XCTAssertEqual(board.filledCount, 9)
        XCTAssertEqual(board.emptyCount, 7)
    }

    func test_formTemplateBoard_setsTheFormOnEachSquare() throws {
        let board = try XCTUnwrap(createBoard(size: .three, source: .template(id: "hisuian-forms")))

        XCTAssertTrue(board.cells.allSatisfy { $0.formId == "hisui" })
    }

    func test_randomRegionBoard_onlyPicksFromThatRegion() throws {
        let board = try XCTUnwrap(createBoard(size: .five, source: .random(region: 0, onlyUncaught: false)))

        XCTAssertEqual(board.filledCount, 25)
        XCTAssertTrue(board.cells.compactMap { $0.number }.allSatisfy { (0..<151).contains($0) })
    }

    func test_randomBoardOfUncaughtPokemon_skipsCaughtOnes_andIgnoresOnesThatGotAway() throws {
        for number in 0..<148 {
            catches.insert(Catch(pokemon: pokemon.get(number: number)!, caughtBall: "poke", caughtDate: nil))
        }
        catches.insert(Catch(pokemon: pokemon.get(number: 150)!, caughtBall: CatchRules.noBall, caughtDate: nil, isFailed: true))
        catches.save()

        let board = try XCTUnwrap(createBoard(size: .three, source: .random(region: 0, onlyUncaught: true)))

        XCTAssertEqual(Set(board.cells.compactMap { $0.number }), [148, 149, 150])
    }

    func test_randomBoard_withNothingLeftToPick_isNotCreated() {
        for number in 0..<151 {
            catches.insert(Catch(pokemon: pokemon.get(number: number)!, caughtBall: "poke", caughtDate: nil))
        }
        catches.save()

        XCTAssertNil(createBoard(size: .three, source: .random(region: 0, onlyUncaught: true)))
        XCTAssertTrue(boards.getAll().isEmpty)
    }

    func test_templateSummaries_countPokemonAndPickACover() throws {
        let summaries = GetBingoTemplatesHandler(templates: templates, pokemonRepository: pokemon).handle(GetBingoTemplatesQuery())

        let alolan = try XCTUnwrap(summaries.first { $0.id == "alolan-forms" })
        XCTAssertEqual(alolan.pokemonCount, 18)
        XCTAssertEqual(alolan.coverFormId, "alola")
        XCTAssertEqual(summaries.first { $0.id == "starters" }?.coverPokemonName, "Bulbasaur")
    }
}
