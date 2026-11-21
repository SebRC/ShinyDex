import XCTest
import CoreData
@testable import ShinyDex

final class BackupPersistenceTests: XCTestCase {
    private var store: TestStore!

    override func setUpWithError() throws {
        store = try TestStore()
        let pokemon = CoreDataPokemonRepository(managedContext: store.context)
        for (number, name) in ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"].enumerated() {
            pokemon.insert(Pokemon(newlyAddedNamed: name, number: number))
        }
    }

    override func tearDownWithError() throws {
        try store.destroy()
        store = nil
    }

    private func makeContainer() -> AppContainer {
        return AppContainer(coreDataStack: store.stack, resourceLoader: StubResourceLoader(), keyValueStore: InMemoryKeyValueStore(), locationLinkProvider: SerebiiLocationLinkProvider(), backupFolder: InMemoryBackupFolder())
    }

    private func logCatch(_ number: Int, ball: String, in container: AppContainer) -> Catch {
        let caught = Catch(number: number, caughtBall: ball, game: .Scarlet, huntMethod: .Masuda, encounters: 100, isShinyCharmActive: true, caughtDate: Date(timeIntervalSince1970: 1_700_000_000))
        container.catchRepository.insert(caught)
        XCTAssertTrue(container.catchRepository.save())
        CaughtBallSync(catchRepository: container.catchRepository, pokemonRepository: container.pokemonRepository).sync(number: number)
        return caught
    }

    func test_restore_replacesEveryCollection_andSurvivesReopening() throws {
        let container = makeContainer()
        let keptCatch = logCatch(1, ball: "ultra", in: container)
        let journey = Journey(name: "Kanto", priority: 0, numbers: [1])
        journey.entries[0].catchId = keptCatch.id
        container.journeyRepository.save(journey)
        container.huntRepository.save(Hunt(name: "Grass", indexes: [0], priority: 0, isCollapsed: false))
        let board = BingoBoard(name: "Starters", priority: 0, size: .three, numbers: [1, 3])
        container.bingoBoardRepository.save(board)
        let venusaur = container.pokemonRepository.get(number: 2)!
        venusaur.encounters = 777
        container.pokemonRepository.save(venusaur)
        container.encounterLedgerRepository.save(EncounterLedger(total: 2000, trackedSince: Date(timeIntervalSince1970: 1_600_000_000)))
        container.setYearlyGoal.handle(SetYearlyGoalCommand(year: 2026, target: 40))
        container.dailyEncountersRepository.save(DailyEncounters(day: EncounterDay(year: 2026, month: 11, day: 20), count: 33))
        let backupData = try container.exportBackup.handle(ExportBackupQuery()).data

        _ = logCatch(3, ball: "dive", in: container)
        keptCatch.nickname = "Changed"
        container.catchRepository.update(keptCatch)
        container.catchRepository.save()
        container.journeyRepository.delete(journey)
        container.huntRepository.save(Hunt(name: "Extra", indexes: [3], priority: 1, isCollapsed: false))
        container.bingoBoardRepository.save(BingoBoard(name: "Extra", priority: 1, size: .four))
        venusaur.encounters = 5
        container.pokemonRepository.save(venusaur)
        container.encounterLedgerRepository.save(EncounterLedger(total: 9999, trackedSince: Date()))
        container.setYearlyGoal.handle(SetYearlyGoalCommand(year: 2026, target: nil))
        container.setYearlyGoal.handle(SetYearlyGoalCommand(year: 2027, target: 5))
        container.dailyEncountersRepository.save(DailyEncounters(day: EncounterDay(year: 2026, month: 11, day: 21), count: 8))

        try container.restoreBackup.handle(RestoreBackupCommand(data: backupData))
        try store.reopen()

        let reopened = makeContainer()
        let catches = reopened.catchRepository.getAll()
        XCTAssertEqual(catches.map { $0.id }, [keptCatch.id])
        XCTAssertNil(catches.first?.nickname)
        XCTAssertEqual(reopened.journeyRepository.getAll().map { $0.id }, [journey.id])
        XCTAssertEqual(reopened.journeyRepository.getAll().first?.entries, journey.entries)
        XCTAssertEqual(reopened.huntRepository.getAll().map { $0.name }, ["Grass"])
        XCTAssertEqual(reopened.bingoBoardRepository.getAll().map { $0.id }, [board.id])
        XCTAssertEqual(reopened.pokemonRepository.get(number: 2)?.encounters, 777)
        XCTAssertEqual(reopened.pokemonRepository.get(number: 1)?.caughtBall, "ultra")
        XCTAssertEqual(reopened.pokemonRepository.get(number: 3)?.caughtBall, CatchRules.noBall)
        XCTAssertEqual(reopened.pokemonRepository.get(number: 3)?.caughtDescription, "Not Caught")
        XCTAssertEqual(reopened.encounterLedgerRepository.get()?.total, 2000)
        XCTAssertEqual(reopened.encounterLedgerRepository.get()?.trackedSince, Date(timeIntervalSince1970: 1_600_000_000))
        XCTAssertEqual(reopened.yearlyGoalRepository.getAll(), [YearlyGoal(year: 2026, target: 40)])
        XCTAssertEqual(reopened.dailyEncountersRepository.getAll(), [DailyEncounters(day: EncounterDay(year: 2026, month: 11, day: 20), count: 33)])
    }

    func test_restore_thatFailsPartWay_leavesTheStoreUntouched() throws {
        let container = makeContainer()
        let journey = Journey(name: "Kanto", priority: 0, numbers: [1])
        container.journeyRepository.save(journey)
        let backupData = try container.exportBackup.handle(ExportBackupQuery()).data

        let laterCatch = logCatch(3, ball: "dive", in: container)
        let journeyRequest = NSFetchRequest<NSManagedObject>(entityName: "JourneyEntity")
        let storedJourney = try XCTUnwrap(try store.context.fetch(journeyRequest).first)
        storedJourney.setValue("not json", forKey: "entries")
        try store.context.save()

        XCTAssertThrowsError(try container.restoreBackup.handle(RestoreBackupCommand(data: backupData))) { error in
            XCTAssertEqual(error as? BackupRestoreError, .saveFailed)
        }
        try store.reopen()

        let reopened = makeContainer()
        XCTAssertEqual(reopened.catchRepository.getAll().map { $0.id }, [laterCatch.id])
        XCTAssertEqual(reopened.pokemonRepository.get(number: 3)?.caughtBall, "dive")
        let reopenedJourney = try XCTUnwrap(try store.context.fetch(journeyRequest).first)
        XCTAssertEqual(reopenedJourney.value(forKey: "entries") as? String, "not json")
    }
}
