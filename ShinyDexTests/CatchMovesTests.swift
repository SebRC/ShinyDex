import XCTest
@testable import ShinyDex

final class CatchMovesTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let pikachu = 0
    private let thunderbolt = LearnableMove(id: 85, name: "Thunderbolt", type: "Electric", pp: 15)
    private let quickAttack = LearnableMove(id: 98, name: "Quick Attack", type: "Normal", pp: 30)
    private let surf = LearnableMove(id: 57, name: "Surf", type: "Water", pp: 15)
    private let wish = LearnableMove(id: 273, name: "Wish", type: "Normal", pp: 10)

    private var learnsets: PokemonLearnsets {
        return PokemonLearnsets(movesById: [85: thunderbolt, 98: quickAttack, 57: surf, 273: wish],
                                learnsets: [[[98], [85], [], []], [[98, 85], [], [273], [57]]],
                                learnsetIndexesByKey: [PokemonLearnsets.Key(number: 0, formId: nil): [.Red: 0, .Platinum: 1],
                                                       PokemonLearnsets.Key(number: 0, formId: "alola"): [.Platinum: 0]])
    }

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Pikachu"])
        catches = InMemoryCatchRepository()
    }

    private func logCatch(in game: Games) throws -> CatchID {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository())
            .handle(LogCatchCommand(number: pikachu, outcome: .caught(ball: "poke"), date: Date(timeIntervalSince1970: 0)))
        let id = CatchID(rawValue: catches.getAll(number: pikachu).last!.id)
        try update(id, .game(game))
        return id
    }

    private func update(_ id: CatchID, _ change: UpdateCatchCommand.Change) throws {
        let forms = PokemonForms(formsByNumber: [pikachu: SpeciesForms(defaultName: nil, alternates: [PokemonForm(id: "alola", name: "Alolan")])])
        try UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon, forms: forms).handle(UpdateCatchCommand(catchId: id, change: change))
    }

    private func getLearnableMoves(_ id: CatchID) -> LearnableMoves? {
        return GetLearnableMovesHandler(catchRepository: catches, pokemonRepository: pokemon, learnsets: learnsets, evolutions: Evolutions(evolvesFrom: [-1])).handle(GetLearnableMovesQuery(catchId: id))
    }

    func test_moves_areUnique_andAtMostFour() {
        XCTAssertEqual(Catch.normalizeMoves([85, 85, 98, 57, 273, 1, 0]), [85, 98, 57, 273])
    }

    func test_learnableMoves_areGroupedByHowTheyreLearned_forTheCatchesGame() throws {
        let id = try logCatch(in: .Platinum)

        let moves = try XCTUnwrap(getLearnableMoves(id))
        XCTAssertEqual(moves.sections.map { $0.method }, [.levelUp, .egg, .tutor])
        XCTAssertEqual(moves.sections.first?.moves.map { $0.name }, ["Quick Attack", "Thunderbolt"], "Sorted by name")
        XCTAssertEqual(getLearnableMoves(try logCatch(in: .Red))?.sections.map { $0.method }, [.levelUp, .machine])
    }

    func test_learnableMoves_includeOtherGamesInTheGeneration_andEarlierEvolutions_markedWithWhereTheyComeFrom() throws {
        let yanma = 0, yanmega = 1
        let lineRepository = InMemoryPokemonRepository(names: ["Yanma", "Yanmega"])
        let hypnosis = LearnableMove(id: 95, name: "Hypnosis", type: "Psychic", pp: 20)
        let learnsets = PokemonLearnsets(movesById: [98: quickAttack, 57: surf, 95: hypnosis],
                                         learnsets: [[[98], [], [], []], [[98], [], [], [57]], [[98, 95], [], [], []]],
                                         learnsetIndexesByKey: [PokemonLearnsets.Key(number: yanmega, formId: nil): [.Platinum: 0, .SoulSilver: 1],
                                                                PokemonLearnsets.Key(number: yanma, formId: nil): [.Platinum: 2]])
        let caught = Catch(number: yanmega, caughtBall: "poke", game: .Platinum, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil)
        catches.insert(caught)

        let moves = try XCTUnwrap(GetLearnableMovesHandler(catchRepository: catches, pokemonRepository: lineRepository, learnsets: learnsets, evolutions: Evolutions(evolvesFrom: [-1, 0]))
            .handle(GetLearnableMovesQuery(catchId: CatchID(rawValue: caught.id))))

        XCTAssertEqual(moves.sections.map { $0.method }, [.levelUp, .tutor])
        XCTAssertEqual(moves.sections[0].moves, [MoveChoice(quickAttack), MoveChoice(hypnosis, learnedAs: "Yanma")], "Native moves first, and only once")
        XCTAssertEqual(moves.sections[1].moves, [MoveChoice(surf, learnedIn: .SoulSilver)])
        XCTAssertEqual(moves.generation, 4)
    }

    func test_forms_useTheirOwnLearnset() throws {
        let id = try logCatch(in: .Platinum)
        try update(id, .form("alola"))

        XCTAssertEqual(getLearnableMoves(id)?.sections.map { $0.method }, [.levelUp, .machine])
    }

    func test_gamesWithoutLearnsetData_offerNoMoves() throws {
        XCTAssertEqual(getLearnableMoves(try logCatch(in: .Sword))?.sections, [])
    }

    func test_savedMoves_showInTheCatchDetails_inOrder() throws {
        let id = try logCatch(in: .Platinum)
        try update(id, .moves([85, 98, 85]))

        XCTAssertEqual(getLearnableMoves(id)?.knownMoves.map { $0.name }, ["Thunderbolt", "Quick Attack"])
        let details = GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: Evolutions(evolvesFrom: [-1]), makeLearnsets: { self.learnsets })
            .handle(GetCatchDetailsQuery(catchId: id))
        XCTAssertEqual(details?.moves, [MoveChoice(id: 85, name: "Thunderbolt", type: "Electric", pp: 15), MoveChoice(id: 98, name: "Quick Attack", type: "Normal", pp: 30)])
    }

    func test_bundledData_knowsLearnsetsPerGameAndForm() throws {
        let bundled = PokemonLearnsetsLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppContainer.self)))

        let platinum = try XCTUnwrap(bundled.findLearnset(of: 24, formId: nil, in: .Platinum))
        XCTAssertTrue(platinum.movesByMethod[.levelUp]?.contains { $0.name == "Thunderbolt" } ?? false)
        XCTAssertNil(bundled.findLearnset(of: 24, formId: nil, in: .Red)?.movesByMethod[.egg], "No breeding in Gen 1")
        XCTAssertTrue(bundled.findLearnset(of: 36, formId: "alola", in: .Sun)?.movesByMethod[.levelUp]?.contains { $0.name == "Powder Snow" } ?? false)
        XCTAssertFalse(bundled.findLearnset(of: 36, formId: nil, in: .Sun)?.contains(181) ?? true, "Kantonian Vulpix doesn't learn Powder Snow")
        XCTAssertEqual(bundled.findMove(85), LearnableMove(id: 85, name: "Thunderbolt", type: "Electric", pp: 15))
    }
}
