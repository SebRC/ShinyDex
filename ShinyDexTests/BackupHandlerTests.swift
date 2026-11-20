import XCTest
@testable import ShinyDex

final class RecordingBackupRepository: BackupRepository {
    private(set) var restored: Backup?
    var failsToRestore = false

    func replaceAll(with backup: Backup) throws {
        guard !failsToRestore else { throw BackupRestoreError.saveFailed }
        restored = backup
    }
}

final class BackupHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var hunts: InMemoryHuntRepository!
    private var journeys: InMemoryJourneyRepository!
    private var bingoBoards: InMemoryBingoBoardRepository!
    private var moves: InMemoryMoveRepository!
    private var backups: RecordingBackupRepository!
    private let exportDate = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "UTC"), year: 2026, month: 11, day: 20, hour: 9, minute: 15, second: 30).date!

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"])
        catches = InMemoryCatchRepository()
        hunts = InMemoryHuntRepository()
        journeys = InMemoryJourneyRepository()
        bingoBoards = InMemoryBingoBoardRepository()
        moves = InMemoryMoveRepository()
        backups = RecordingBackupRepository()
    }

    private func export() throws -> BackupFile {
        return try ExportBackupHandler(pokemonRepository: pokemon, catchRepository: catches, huntRepository: hunts, journeyRepository: journeys,
                                       bingoBoardRepository: bingoBoards, moveRepository: moves, makeCurrentDate: { self.exportDate })
            .handle(ExportBackupQuery())
    }

    private func restore(_ data: Data) throws {
        try RestoreBackupHandler(backupRepository: backups, pokemonRepository: pokemon).handle(RestoreBackupCommand(data: data))
    }

    private func makeFullCatch() -> Catch {
        let caught = Catch(number: 1, caughtBall: "ultra", game: .Scarlet, huntMethod: .Masuda, encounters: 1234, isShinyCharmActive: true, caughtDate: exportDate, isFailed: false)
        caught.evs = EffortValues(encoded: "4,252,0,0,0,252")
        caught.evolvedFrom = 0
        caught.nickname = "Leafy"
        caught.gender = .female
        caught.nature = .timid
        caught.ivs = IndividualValues(encoded: "31,,31,0,31,31")
        caught.formId = "east"
        return caught
    }

    private func seedEverything() -> (caught: Catch, hunt: Hunt, journey: Journey, board: BingoBoard) {
        let caught = makeFullCatch()
        catches.insert(caught)
        catches.insert(Catch(number: 3, caughtBall: CatchRules.noBall, game: .Red, huntMethod: .Encounters, encounters: 50, isShinyCharmActive: false, caughtDate: nil, isFailed: true))
        catches.save()
        let hunt = Hunt(name: "Grass", indexes: [0, 2], priority: 1, isCollapsed: true)
        hunts.save(hunt)
        let journey = Journey(name: "Kanto", priority: 0, numbers: [0, 3])
        journey.entries[0].catchId = caught.id
        journey.entries[1].phaseCatchIds = [UUID()]
        journey.entries[1].formId = "alola"
        journeys.save(journey)
        let board = BingoBoard(name: "Starters", priority: 0, size: .three, numbers: [0, 3])
        board.link(caught.id, at: 0)
        board.setForm("galar", at: 1)
        bingoBoards.save(board)
        moves.insert(ActiveMoves(moves: [ActiveMove(name: "False Swipe", maxPP: 64, remainingPP: 12, type: "Normal")], pressureActive: true))
        let venusaur = pokemon.get(number: 2)!
        venusaur.encounters = 4321
        venusaur.isBeingHunted = true
        venusaur.game = .Sword
        venusaur.generation = 8
        venusaur.huntMethod = .Masuda
        venusaur.isShinyCharmActive = true
        venusaur.shinyOdds = 512
        venusaur.increment = 5
        pokemon.save(venusaur)
        return (caught, hunt, journey, board)
    }

    // MARK: Export

    func test_export_namesTheFileAfterTheExportDate() throws {
        XCTAssertEqual(try export().fileName, "ShinyDex Backup 2026-11-20.json")
    }

    func test_export_writesTheCurrentFormatVersion() throws {
        let json = try JSONSerialization.jsonObject(with: try export().data) as? [String: Any]

        XCTAssertEqual(json?["formatVersion"] as? Int, BackupDocument.currentFormatVersion)
    }

    func test_export_thenRestore_handsEveryRecordBackUnchanged() throws {
        let seeded = seedEverything()
        let file = try export()

        try restore(file.data)

        let backup = try XCTUnwrap(backups.restored)
        XCTAssertEqual(backup.catches.count, 2)
        let caught = try XCTUnwrap(backup.catches.first { $0.id == seeded.caught.id })
        XCTAssertEqual(caught.number, 1)
        XCTAssertEqual(caught.caughtBall, "ultra")
        XCTAssertEqual(caught.game, .Scarlet)
        XCTAssertEqual(caught.huntMethod, .Masuda)
        XCTAssertEqual(caught.encounters, 1234)
        XCTAssertTrue(caught.isShinyCharmActive)
        XCTAssertEqual(caught.caughtDate, exportDate)
        XCTAssertFalse(caught.isFailed)
        XCTAssertEqual(caught.evs, seeded.caught.evs)
        XCTAssertEqual(caught.evolvedFrom, 0)
        XCTAssertEqual(caught.nickname, "Leafy")
        XCTAssertEqual(caught.gender, .female)
        XCTAssertEqual(caught.nature, .timid)
        XCTAssertEqual(caught.ivs, seeded.caught.ivs)
        XCTAssertEqual(caught.formId, "east")
        XCTAssertTrue(try XCTUnwrap(backup.catches.first { $0.id != seeded.caught.id }).isFailed)

        let hunt = try XCTUnwrap(backup.hunts.first)
        XCTAssertEqual(hunt.id, seeded.hunt.id)
        XCTAssertEqual(hunt.name, "Grass")
        XCTAssertEqual(hunt.indexes, [0, 2])
        XCTAssertEqual(hunt.priority, 1)
        XCTAssertTrue(hunt.isCollapsed)

        let journey = try XCTUnwrap(backup.journeys.first)
        XCTAssertEqual(journey.id, seeded.journey.id)
        XCTAssertEqual(journey.name, "Kanto")
        XCTAssertEqual(journey.createdDate.timeIntervalSince1970, seeded.journey.createdDate.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(journey.entries, seeded.journey.entries)

        let board = try XCTUnwrap(backup.bingoBoards.first)
        XCTAssertEqual(board.id, seeded.board.id)
        XCTAssertEqual(board.size, .three)
        XCTAssertEqual(board.cells, seeded.board.cells)

        let activeMoves = try XCTUnwrap(backup.activeMoves)
        XCTAssertTrue(activeMoves.pressureActive)
        XCTAssertEqual(activeMoves.moves.map { $0.name }, ["False Swipe"])
        XCTAssertEqual(activeMoves.moves.first?.remainingPP, 12)
    }

    // MARK: Pokémon hunt state

    func test_restore_onTheSameData_leavesEveryPokemonAlone() throws {
        _ = seedEverything()
        CaughtBallSync(catchRepository: catches, pokemonRepository: pokemon).sync(number: 1)

        try restore(try export().data)

        XCTAssertEqual(backups.restored?.pokemon.count, 0)
    }

    func test_restore_bringsBackHuntSettings_andDerivesCaughtBallsFromTheRestoredCatches() throws {
        _ = seedEverything()
        let file = try export()
        setUp()

        try restore(file.data)

        let restored = try XCTUnwrap(backups.restored)
        XCTAssertEqual(restored.pokemon.map { $0.number }, [1, 2])
        let ivysaur = restored.pokemon[0]
        XCTAssertEqual(ivysaur.caughtBall, "ultra")
        XCTAssertEqual(ivysaur.caughtDescription, "Caught")
        let venusaur = restored.pokemon[1]
        XCTAssertEqual(venusaur.name, "Venusaur")
        XCTAssertEqual(venusaur.encounters, 4321)
        XCTAssertTrue(venusaur.isBeingHunted)
        XCTAssertEqual(venusaur.game, .Sword)
        XCTAssertEqual(venusaur.generation, 8)
        XCTAssertEqual(venusaur.huntMethod, .Masuda)
        XCTAssertTrue(venusaur.isShinyCharmActive)
        XCTAssertEqual(venusaur.shinyOdds, 512)
        XCTAssertEqual(venusaur.increment, 5)
        XCTAssertEqual(venusaur.caughtBall, CatchRules.noBall)
    }

    func test_restore_resetsPokemonMissingFromTheBackup() throws {
        let file = try export()
        let charmeleon = Pokemon(newlyAddedNamed: "Charmeleon", number: 4)
        charmeleon.encounters = 99
        charmeleon.isBeingHunted = true
        pokemon.insert(charmeleon)

        try restore(file.data)

        let reset = try XCTUnwrap(backups.restored?.pokemon.first { $0.number == 4 })
        XCTAssertEqual(reset.encounters, 0)
        XCTAssertFalse(reset.isBeingHunted)
    }

    // MARK: Summary

    func test_summary_countsCaughtShiniesAndCollections() throws {
        _ = seedEverything()

        let summary = try GetBackupSummaryHandler().handle(GetBackupSummaryQuery(data: try export().data))

        XCTAssertEqual(summary, BackupSummary(createdDate: exportDate, catchCount: 1, huntCount: 1, journeyCount: 1, bingoBoardCount: 1))
    }

    // MARK: Invalid files

    func test_restore_ofAFileThatIsNotABackup_failsWithoutTouchingData() {
        XCTAssertThrowsError(try restore(Data("{\"hello\": 1}".utf8))) { error in
            XCTAssertEqual(error as? BackupFileError, .unreadable)
        }
        XCTAssertNil(backups.restored)
    }

    func test_restore_ofABackupFromANewerFormat_isRefused() throws {
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: try export().data) as? [String: Any])
        json["formatVersion"] = BackupDocument.currentFormatVersion + 1

        XCTAssertThrowsError(try restore(try JSONSerialization.data(withJSONObject: json))) { error in
            XCTAssertEqual(error as? BackupFileError, .newerFormat)
        }
        XCTAssertNil(backups.restored)
    }

    func test_restore_ofABackupWithAnUnknownGame_isRefused() throws {
        _ = seedEverything()
        let text = String(decoding: try export().data, as: UTF8.self).replacingOccurrences(of: "\"Scarlet\"", with: "\"Unknown Game\"")

        XCTAssertThrowsError(try restore(Data(text.utf8))) { error in
            XCTAssertEqual(error as? BackupFileError, .unreadable)
        }
    }

    func test_restore_passesOnRepositoryFailures() throws {
        backups.failsToRestore = true

        XCTAssertThrowsError(try restore(try export().data)) { error in
            XCTAssertEqual(error as? BackupRestoreError, .saveFailed)
        }
    }
}
