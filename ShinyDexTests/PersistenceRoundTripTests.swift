import XCTest
import CoreData
@testable import ShinyDex

final class PersistenceRoundTripTests: XCTestCase {
    private var store: TestStore!

    override func setUpWithError() throws {
        store = try TestStore()
    }

    override func tearDownWithError() throws {
        try store.destroy()
        store = nil
    }

    private func makeDate(_ day: Int) -> Date {
        return DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "UTC"), year: 2025, month: 3, day: day, hour: 14, minute: 30).date!
    }

    // MARK: Catch

    func test_catch_withEveryFieldSet_survivesSaveAndReload() throws {
        let original = Catch(number: 25, caughtBall: "ultra", game: .Scarlet, huntMethod: .Masuda, encounters: 1234, isShinyCharmActive: true, caughtDate: makeDate(4), isFailed: true)
        original.evs = EffortValues(encoded: "4,252,0,0,0,252")
        original.evolvedFrom = 171
        original.nickname = "Sparky"
        original.gender = .female
        original.nature = .timid
        original.ability = "static"
        original.moves = [85, 98]
        original.level = 72
        original.phaseCatchIds = [UUID(uuidString: "6B2D4A10-0000-4000-8000-000000000001")!]
        original.ivs = IndividualValues(encoded: "31,,31,0,31,31")
        original.encounterTotalAtFind = 98_765
        let repository = CoreDataCatchRepository(managedContext: store.context)
        repository.insert(original)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let reloaded = CoreDataCatchRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.count, 1)
        let caught = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(caught.id, original.id)
        XCTAssertEqual(caught.number, 25)
        XCTAssertEqual(caught.caughtBall, "ultra")
        XCTAssertEqual(caught.game, .Scarlet)
        XCTAssertEqual(caught.huntMethod, .Masuda)
        XCTAssertEqual(caught.encounters, 1234)
        XCTAssertTrue(caught.isShinyCharmActive)
        XCTAssertEqual(caught.caughtDate, makeDate(4))
        XCTAssertTrue(caught.isFailed)
        XCTAssertEqual(caught.evs, original.evs)
        XCTAssertEqual(caught.evolvedFrom, 171)
        XCTAssertEqual(caught.nickname, "Sparky")
        XCTAssertEqual(caught.gender, .female)
        XCTAssertEqual(caught.nature, .timid)
        XCTAssertEqual(caught.ability, "static")
        XCTAssertEqual(caught.moves, [85, 98])
        XCTAssertEqual(caught.level, 72)
        XCTAssertEqual(caught.phaseCatchIds, original.phaseCatchIds)
        XCTAssertEqual(caught.ivs, original.ivs)
        XCTAssertEqual(caught.encounterTotalAtFind, 98_765)
    }

    func test_catch_withOptionalFieldsEmpty_survivesSaveAndReload() throws {
        let original = Catch(number: 1, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil)
        let repository = CoreDataCatchRepository(managedContext: store.context)
        repository.insert(original)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let entity = try XCTUnwrap(fetchRawRows("CatchEntity").first)
        let caught = try XCTUnwrap(CoreDataCatchRepository(managedContext: store.context).getAll().first)

        XCTAssertNil(entity.value(forKey: "evs"), "Empty EVs are stored as nil")
        XCTAssertEqual(entity.value(forKey: "evolvedFrom") as? Int, -1, "No pre-evolution is stored as -1")
        XCTAssertNil(entity.value(forKey: "ivs"), "Unknown IVs are stored as nil")
        XCTAssertNil(entity.value(forKey: "nickname"))
        XCTAssertNil(entity.value(forKey: "gender"))
        XCTAssertNil(entity.value(forKey: "nature"))
        XCTAssertNil(caught.caughtDate)
        XCTAssertTrue(caught.evs.isEmpty)
        XCTAssertNil(caught.evolvedFrom)
        XCTAssertFalse(caught.isFailed)
        XCTAssertNil(caught.nickname)
        XCTAssertNil(caught.gender)
        XCTAssertNil(caught.nature)
        XCTAssertNil(caught.ability)
        XCTAssertEqual(caught.moves, [])
        XCTAssertNil(caught.level)
        XCTAssertEqual(caught.phaseCatchIds, [])
        XCTAssertTrue(caught.ivs.isEmpty)
    }

    func test_catch_update_andDelete_arePersisted() throws {
        let first = Catch(number: 4, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 10, isShinyCharmActive: false, caughtDate: makeDate(1))
        let second = Catch(number: 7, caughtBall: "great", game: .Red, huntMethod: .Encounters, encounters: 20, isShinyCharmActive: false, caughtDate: makeDate(2))
        let repository = CoreDataCatchRepository(managedContext: store.context)
        repository.insert(first)
        repository.insert(second)
        XCTAssertTrue(repository.save())

        first.encounters = 99
        repository.update(first)
        repository.delete(second)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let reloaded = CoreDataCatchRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.map { $0.id }, [first.id])
        XCTAssertEqual(reloaded.first?.encounters, 99)
    }

    func test_catch_fetchByNumber_returnsOnlyThatSpecies() throws {
        let repository = CoreDataCatchRepository(managedContext: store.context)
        for number in [1, 4, 4] {
            repository.insert(Catch(number: number, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil))
        }
        XCTAssertTrue(repository.save())

        try store.reopen()

        XCTAssertEqual(CoreDataCatchRepository(managedContext: store.context).getAll(number: 4).count, 2)
    }

    func test_catchForm_survivesSaveAndReload() throws {
        let original = Catch(number: 422, caughtBall: "dive", game: .Platinum, huntMethod: .Encounters, encounters: 10, isShinyCharmActive: false, caughtDate: makeDate(5))
        original.formId = "east"
        let repository = CoreDataCatchRepository(managedContext: store.context)
        repository.insert(original)
        XCTAssertTrue(repository.save())

        try store.reopen()

        XCTAssertEqual(CoreDataCatchRepository(managedContext: store.context).getAll().first?.formId, "east")
    }

    // MARK: Hunt

    func test_hunt_survivesSaveAndReload() throws {
        let hunt = Hunt(name: "Starters", pokemon: [], priority: 3)
        hunt.indexes = [0, 3, 6]
        hunt.isCollapsed = true
        CoreDataHuntRepository(managedContext: store.context).save(hunt)

        try store.reopen()
        let reloaded = CoreDataHuntRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.count, 1)
        let stored = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(stored.name, "Starters")
        XCTAssertEqual(stored.indexes, [0, 3, 6])
        XCTAssertEqual(stored.priority, 3)
        XCTAssertTrue(stored.isCollapsed)
    }

    func test_hunt_keepsItsIdAcrossReloads() throws {
        let hunt = Hunt(name: "Starters", pokemon: [], priority: 0)
        CoreDataHuntRepository(managedContext: store.context).save(hunt)

        try store.reopen()
        let reloaded = try XCTUnwrap(CoreDataHuntRepository(managedContext: store.context).getAll().first)
        XCTAssertEqual(reloaded.id, hunt.id)

        reloaded.name = "Renamed"
        try store.reopen()
        CoreDataHuntRepository(managedContext: store.context).save(reloaded)
        try store.reopen()
        XCTAssertEqual(CoreDataHuntRepository(managedContext: store.context).getAll().map { $0.name }, ["Renamed"], "A hunt from an earlier session updates its own row")
    }

    func test_assignMissingHuntIds_onlyFillsGapsAndIsStable() throws {
        let entity = NSEntityDescription.entity(forEntityName: "HuntEntity", in: store.context)!
        let withId = NSManagedObject(entity: entity, insertInto: store.context)
        let existingId = UUID()
        withId.setValue(existingId, forKey: "id")
        for name in ["Without id A", "Without id B"] {
            let row = NSManagedObject(entity: entity, insertInto: store.context)
            row.setValue(name, forKey: "name")
        }
        try store.context.save()

        CoreDataHuntRepository.assignMissingIds(in: store.context)
        let firstPass = Dictionary(uniqueKeysWithValues: fetchRawRows("HuntEntity").map { ($0.objectID, $0.value(forKey: "id") as? UUID) })
        CoreDataHuntRepository.assignMissingIds(in: store.context)
        let secondPass = Dictionary(uniqueKeysWithValues: fetchRawRows("HuntEntity").map { ($0.objectID, $0.value(forKey: "id") as? UUID) })

        XCTAssertEqual(withId.value(forKey: "id") as? UUID, existingId)
        XCTAssertEqual(Set(firstPass.values.compactMap { $0 }).count, 3)
        XCTAssertEqual(firstPass, secondPass)
    }

    func test_hunt_update_andDelete_arePersisted() throws {
        let kept = Hunt(name: "Kept", pokemon: [], priority: 0)
        let removed = Hunt(name: "Removed", pokemon: [], priority: 1)
        let repository = CoreDataHuntRepository(managedContext: store.context)
        repository.save(kept)
        repository.save(removed)

        kept.name = "Renamed"
        kept.indexes = [150]
        repository.save(kept)
        repository.delete(removed)

        try store.reopen()
        let reloaded = CoreDataHuntRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.map { $0.name }, ["Renamed"])
        XCTAssertEqual(reloaded.first?.indexes, [150])
    }

    // MARK: Journey

    func test_journey_survivesSaveAndReload() throws {
        let journey = Journey(name: "Kanto dream team", priority: 2, numbers: [0, 3, 6])
        let catchId = UUID()
        journey.entries[1].catchId = catchId
        journey.entries[2].phaseCatchIds = [UUID(), UUID()]
        XCTAssertTrue(CoreDataJourneyRepository(managedContext: store.context).save(journey))

        try store.reopen()
        let reloaded = CoreDataJourneyRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.count, 1)
        let stored = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(stored.id, journey.id)
        XCTAssertEqual(stored.name, "Kanto dream team")
        XCTAssertEqual(stored.priority, 2)
        XCTAssertEqual(stored.createdDate, journey.createdDate)
        XCTAssertEqual(stored.entries, journey.entries)
        XCTAssertEqual(stored.entries[1].catchId, catchId)
    }

    func test_journey_entries_areStoredWithTheirCurrentJsonKeys() throws {
        let journey = Journey(name: "Format", priority: 0, numbers: [25])
        journey.entries[0].catchId = UUID()
        XCTAssertTrue(CoreDataJourneyRepository(managedContext: store.context).save(journey))

        try store.reopen()
        let entity = try XCTUnwrap(fetchRawRows("JourneyEntity").first)
        let json = try XCTUnwrap((entity.value(forKey: "entries") as? String)?.data(using: .utf8))
        let entries = try XCTUnwrap(JSONSerialization.jsonObject(with: json) as? [[String: Any]])

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(Set(entries[0].keys), ["id", "number", "catchId"])
        XCTAssertEqual(entries[0]["number"] as? Int, 25)
        XCTAssertEqual(entries[0]["id"] as? String, journey.entries[0].id.uuidString)
        XCTAssertEqual(entries[0]["catchId"] as? String, journey.entries[0].catchId?.uuidString)
    }

    func test_journey_delete_isPersisted() throws {
        let journey = Journey(name: "Gone", priority: 0, numbers: [1])
        let repository = CoreDataJourneyRepository(managedContext: store.context)
        XCTAssertTrue(repository.save(journey))
        repository.delete(journey)

        try store.reopen()

        XCTAssertTrue(CoreDataJourneyRepository(managedContext: store.context).getAll().isEmpty)
    }

    func test_journeyEntryForm_survivesSaveAndReload_andIsLeftOutWhenUnset() throws {
        let journey = Journey(name: "Seas", priority: 0, numbers: [421, 422])
        journey.entries[1].formId = "east"
        CoreDataJourneyRepository(managedContext: store.context).save(journey)

        try store.reopen()

        let stored = try XCTUnwrap(CoreDataJourneyRepository(managedContext: store.context).getAll().first)
        XCTAssertEqual(stored.entries.map { $0.formId }, [nil, "east"])
        let json = try XCTUnwrap(fetchRawRows("JourneyEntity").first?.value(forKey: "entries") as? String)
        XCTAssertEqual(json.components(separatedBy: "\"form\"").count - 1, 1)
    }

    func test_bingoCellForm_survivesSaveAndReload() throws {
        let board = BingoBoard(name: "Seas", priority: 0, size: .three, numbers: [422])
        board.setForm("east", at: 0)
        CoreDataBingoBoardRepository(managedContext: store.context).save(board)

        try store.reopen()

        XCTAssertEqual(CoreDataBingoBoardRepository(managedContext: store.context).getAll().first?.cells[0].formId, "east")
    }

    // MARK: Bingo board

    func test_bingoBoard_survivesSaveAndReload() throws {
        let board = BingoBoard(name: "Shiny bingo", priority: 3, size: .four, numbers: [25, 133, 448])
        board.link(UUID(), at: 1)
        board.swap(2, 15)
        XCTAssertTrue(CoreDataBingoBoardRepository(managedContext: store.context).save(board))

        try store.reopen()
        let reloaded = CoreDataBingoBoardRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.count, 1)
        let stored = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(stored.id, board.id)
        XCTAssertEqual(stored.name, "Shiny bingo")
        XCTAssertEqual(stored.priority, 3)
        XCTAssertEqual(stored.size, .four)
        XCTAssertEqual(stored.createdDate, board.createdDate)
        XCTAssertEqual(stored.cells, board.cells)
    }

    func test_bingoBoard_cells_areStoredWithTheirCurrentJsonKeys() throws {
        let board = BingoBoard(name: "Format", priority: 0, size: .three, numbers: [25, 26])
        let catchId = UUID()
        board.link(catchId, at: 0)
        XCTAssertTrue(CoreDataBingoBoardRepository(managedContext: store.context).save(board))

        try store.reopen()
        let entity = try XCTUnwrap(fetchRawRows("BingoBoardEntity").first)
        let json = try XCTUnwrap((entity.value(forKey: "cells") as? String)?.data(using: .utf8))
        let cells = try XCTUnwrap(JSONSerialization.jsonObject(with: json) as? [[String: Any]])

        XCTAssertEqual(entity.value(forKey: "size") as? Int, 3)
        XCTAssertEqual(cells.count, 9)
        XCTAssertEqual(Set(cells[0].keys), ["number", "catchId"])
        XCTAssertEqual(cells[0]["number"] as? Int, 25)
        XCTAssertEqual(cells[0]["catchId"] as? String, catchId.uuidString)
        XCTAssertEqual(Set(cells[1].keys), ["number"])
        XCTAssertTrue(cells[2].isEmpty)
    }

    func test_bingoBoard_delete_isPersisted() throws {
        let board = BingoBoard(name: "Gone", priority: 0, size: .three)
        let repository = CoreDataBingoBoardRepository(managedContext: store.context)
        XCTAssertTrue(repository.save(board))
        repository.delete(board)

        try store.reopen()

        XCTAssertTrue(CoreDataBingoBoardRepository(managedContext: store.context).getAll().isEmpty)
    }

    func test_bingoBoard_withUnreadableStoredCells_isNotOverwritten() throws {
        let board = BingoBoard(name: "Damaged", priority: 0, size: .three, numbers: [1])
        XCTAssertTrue(CoreDataBingoBoardRepository(managedContext: store.context).save(board))
        let corrupt = "[{\"number\":"
        try XCTUnwrap(fetchRawRows("BingoBoardEntity").first).setValue(corrupt, forKey: "cells")
        try store.context.save()

        try store.reopen()
        let repository = CoreDataBingoBoardRepository(managedContext: store.context)
        let loaded = try XCTUnwrap(repository.getAll().first)
        loaded.name = "Renamed"
        XCTAssertFalse(repository.save(loaded))

        try store.reopen()
        let row = try XCTUnwrap(fetchRawRows("BingoBoardEntity").first)
        XCTAssertEqual(row.value(forKey: "cells") as? String, corrupt)
        XCTAssertEqual(row.value(forKey: "name") as? String, "Damaged")
    }

    // MARK: Pokemon

    func test_pokemon_createdWithDefaults_survivesReload() throws {
        CoreDataPokemonRepository(managedContext: store.context).insert(Pokemon(newlyAddedNamed: "Bulbasaur", number: 0))

        try store.reopen()
        let reloaded = CoreDataPokemonRepository(managedContext: store.context).getAll()

        XCTAssertEqual(reloaded.count, 1)
        let pokemon = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(pokemon.name, "Bulbasaur")
        XCTAssertEqual(pokemon.number, 0)
        XCTAssertEqual(pokemon.encounters, 0)
        XCTAssertEqual(pokemon.caughtDescription, "Not Caught")
        XCTAssertEqual(pokemon.caughtBall, "none")
        XCTAssertFalse(pokemon.isBeingHunted)
        XCTAssertEqual(pokemon.generation, 2)
        XCTAssertFalse(pokemon.isShinyCharmActive)
        XCTAssertEqual(pokemon.shinyOdds, 8192)
        XCTAssertEqual(pokemon.huntMethod, .Encounters)
        XCTAssertEqual(pokemon.increment, 1)
        XCTAssertEqual(pokemon.game, .Red)
        XCTAssertEqual(pokemon.phases, [])
    }

    func test_pokemon_changes_surviveReload() throws {
        CoreDataPokemonRepository(managedContext: store.context).insert(Pokemon(newlyAddedNamed: "Ralts", number: 279))
        try store.reopen()
        let pokemon = try XCTUnwrap(CoreDataPokemonRepository(managedContext: store.context).getAll().first)
        pokemon.encounters = 4321
        pokemon.caughtDescription = "Caught"
        pokemon.caughtBall = "dream"
        pokemon.isBeingHunted = true
        pokemon.generation = 9
        pokemon.isShinyCharmActive = true
        pokemon.shinyOdds = 1365
        pokemon.huntMethod = .Masuda
        pokemon.increment = 3
        pokemon.game = .Scarlet
        pokemon.phases = [HuntPhase(catchId: UUID(uuidString: "6B2D4A10-0000-4000-8000-000000000002")!, encounters: 812)]
        CoreDataPokemonRepository(managedContext: store.context).save(pokemon)

        try store.reopen()
        let reloaded = try XCTUnwrap(CoreDataPokemonRepository(managedContext: store.context).getAll().first)

        XCTAssertEqual(reloaded.encounters, 4321)
        XCTAssertEqual(reloaded.caughtDescription, "Caught")
        XCTAssertEqual(reloaded.caughtBall, "dream")
        XCTAssertTrue(reloaded.isBeingHunted)
        XCTAssertEqual(reloaded.generation, 9)
        XCTAssertTrue(reloaded.isShinyCharmActive)
        XCTAssertEqual(reloaded.shinyOdds, 1365)
        XCTAssertEqual(reloaded.huntMethod, .Masuda)
        XCTAssertEqual(reloaded.increment, 3)
        XCTAssertEqual(reloaded.game, .Scarlet)
        XCTAssertEqual(reloaded.phases, pokemon.phases)
    }

    func test_pokemon_areReturnedSortedByNumber() throws {
        let repository = CoreDataPokemonRepository(managedContext: store.context)
        repository.insert(Pokemon(newlyAddedNamed: "Squirtle", number: 6))
        repository.insert(Pokemon(newlyAddedNamed: "Bulbasaur", number: 0))
        repository.insert(Pokemon(newlyAddedNamed: "Charmander", number: 3))

        try store.reopen()

        XCTAssertEqual(CoreDataPokemonRepository(managedContext: store.context).getAll().map { $0.number }, [0, 3, 6])
    }

    // MARK: Active moves

    func test_activeMoves_surviveSaveAndReload() throws {
        let spore = ActiveMove(name: "Spore", maxPP: 24, remainingPP: 17, type: "grass")
        CoreDataMoveRepository(managedContext: store.context).insert(ActiveMoves(moves: [spore], pressureActive: false))

        try store.reopen()
        let activeMoves = try XCTUnwrap(CoreDataMoveRepository(managedContext: store.context).getActiveMoves())
        XCTAssertEqual(activeMoves.moves.map { $0.name }, ["Spore"])
        XCTAssertEqual(activeMoves.moves.first?.remainingPP, 17)
        XCTAssertFalse(activeMoves.pressureActive)

        activeMoves.moves[0].remainingPP = 9
        activeMoves.pressureActive = true
        CoreDataMoveRepository(managedContext: store.context).save(activeMoves)

        try store.reopen()
        let reloaded = try XCTUnwrap(CoreDataMoveRepository(managedContext: store.context).getActiveMoves())
        XCTAssertEqual(reloaded.moves.map { $0.remainingPP }, [9])
        XCTAssertTrue(reloaded.pressureActive)
        XCTAssertEqual(fetchRawRows("ActiveMovesEntity").count, 1)
    }

    func test_activeMoves_areStoredWithTheirCurrentJsonKeys() throws {
        CoreDataMoveRepository(managedContext: store.context).insert(ActiveMoves(moves: [ActiveMove(name: "Spore", maxPP: 24, remainingPP: 17, type: "grass")], pressureActive: false))

        try store.reopen()
        let json = try XCTUnwrap((fetchRawRows("ActiveMovesEntity").first?.value(forKey: "json") as? String)?.data(using: .utf8))
        let moves = try XCTUnwrap(JSONSerialization.jsonObject(with: json) as? [[String: Any]])

        XCTAssertEqual(moves.count, 1)
        XCTAssertEqual(Set(moves[0].keys), ["name", "maxPP", "remainingPP", "type"])
        XCTAssertEqual(moves[0]["name"] as? String, "Spore")
        XCTAssertEqual(moves[0]["remainingPP"] as? Int, 17)
    }

    // MARK: Progress

    func test_encounterLedger_survivesSaveAndReload_inASingleRow() throws {
        XCTAssertNil(CoreDataEncounterLedgerRepository(managedContext: store.context).get())
        let ledger = EncounterLedger(startingOn: makeDate(2))
        ledger.count(1500)
        CoreDataEncounterLedgerRepository(managedContext: store.context).save(ledger)
        ledger.count(25)
        CoreDataEncounterLedgerRepository(managedContext: store.context).save(ledger)

        try store.reopen()
        let reloaded = try XCTUnwrap(CoreDataEncounterLedgerRepository(managedContext: store.context).get())

        XCTAssertEqual(reloaded.total, 1525)
        XCTAssertEqual(reloaded.trackedSince, makeDate(2))
        XCTAssertEqual(fetchRawRows("EncounterLedgerEntity").count, 1)
    }

    func test_yearlyGoals_survivesSaveAndReload_withOneRowPerYear() throws {
        let repository = CoreDataYearlyGoalRepository(managedContext: store.context)
        repository.save(YearlyGoal(year: 2026, target: 20))
        repository.save(YearlyGoal(year: 2025, target: 10))
        repository.save(YearlyGoal(year: 2026, target: 35))

        try store.reopen()
        XCTAssertEqual(CoreDataYearlyGoalRepository(managedContext: store.context).getAll(), [YearlyGoal(year: 2025, target: 10), YearlyGoal(year: 2026, target: 35)])

        CoreDataYearlyGoalRepository(managedContext: store.context).delete(year: 2025)
        try store.reopen()
        XCTAssertEqual(CoreDataYearlyGoalRepository(managedContext: store.context).getAll(), [YearlyGoal(year: 2026, target: 35)])
    }

    func test_dailyEncounters_surviveSaveAndReload_withOneRowPerDay() throws {
        let repository = CoreDataDailyEncountersRepository(managedContext: store.context)
        let first = EncounterDay(year: 2026, month: 11, day: 20), second = EncounterDay(year: 2026, month: 11, day: 21)
        repository.save(DailyEncounters(day: second, count: 4))
        repository.save(DailyEncounters(day: first, count: 30))
        repository.save(DailyEncounters(day: second, count: 9))

        try store.reopen()
        let reloaded = CoreDataDailyEncountersRepository(managedContext: store.context)

        XCTAssertEqual(reloaded.getAll(), [DailyEncounters(day: first, count: 30), DailyEncounters(day: second, count: 9)])
        XCTAssertEqual(reloaded.get(day: second)?.count, 9)
        XCTAssertEqual(fetchRawRows("DailyEncounterEntity").map { $0.value(forKey: "day") as? String }.sorted { ($0 ?? "") < ($1 ?? "") }, ["2026-11-20", "2026-11-21"])

        reloaded.replaceAll(with: [DailyEncounters(day: first, count: 1)])
        try store.reopen()
        XCTAssertEqual(CoreDataDailyEncountersRepository(managedContext: store.context).getAll(), [DailyEncounters(day: first, count: 1)])
    }

    // MARK: Data safety

    func test_journey_withUnreadableStoredEntries_isNotOverwritten() throws {
        let journey = Journey(name: "Damaged", priority: 0, numbers: [1])
        XCTAssertTrue(CoreDataJourneyRepository(managedContext: store.context).save(journey))
        let corrupt = "{not json"
        try XCTUnwrap(fetchRawRows("JourneyEntity").first).setValue(corrupt, forKey: "entries")
        try store.context.save()

        try store.reopen()
        let repository = CoreDataJourneyRepository(managedContext: store.context)
        let loaded = try XCTUnwrap(repository.getAll().first)
        XCTAssertTrue(loaded.entries.isEmpty)
        loaded.name = "Renamed"
        XCTAssertFalse(repository.save(loaded))

        try store.reopen()
        let row = try XCTUnwrap(fetchRawRows("JourneyEntity").first)
        XCTAssertEqual(row.value(forKey: "entries") as? String, corrupt)
        XCTAssertEqual(row.value(forKey: "name") as? String, "Damaged")
    }

    func test_activeMoves_withUnreadableStoredJson_areNotOverwritten() throws {
        CoreDataMoveRepository(managedContext: store.context).insert(ActiveMoves(moves: [], pressureActive: false))
        let corrupt = "[{\"name\":"
        try XCTUnwrap(fetchRawRows("ActiveMovesEntity").first).setValue(corrupt, forKey: "json")
        try store.context.save()

        try store.reopen()
        let repository = CoreDataMoveRepository(managedContext: store.context)
        XCTAssertEqual(repository.getActiveMoves()?.moves.count, 0)
        repository.save(ActiveMoves(moves: [ActiveMove(name: "Tackle", maxPP: 35, remainingPP: 35, type: "normal")], pressureActive: true))

        try store.reopen()
        XCTAssertEqual(fetchRawRows("ActiveMovesEntity").first?.value(forKey: "json") as? String, corrupt)
    }

    func test_hunt_savedThroughAnotherRepositoryInstance_updatesTheSameRow() throws {
        CoreDataHuntRepository(managedContext: store.context).save(Hunt(name: "Original", pokemon: [], priority: 0))
        try store.reopen()

        let loaded = try XCTUnwrap(CoreDataHuntRepository(managedContext: store.context).getAll().first)
        loaded.name = "Updated"
        CoreDataHuntRepository(managedContext: store.context).save(loaded)
        CoreDataHuntRepository(managedContext: store.context).delete(Hunt(name: "Never saved", pokemon: [], priority: 1))

        try store.reopen()
        XCTAssertEqual(CoreDataHuntRepository(managedContext: store.context).getAll().map { $0.name }, ["Updated"])
    }

    func test_catch_savedThroughAnotherRepositoryInstance_updatesTheSameRow() throws {
        let original = Catch(number: 1, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 5, isShinyCharmActive: false, caughtDate: nil)
        let repository = CoreDataCatchRepository(managedContext: store.context)
        repository.insert(original)
        XCTAssertTrue(repository.save())
        try store.reopen()

        let loaded = try XCTUnwrap(CoreDataCatchRepository(managedContext: store.context).getAll().first)
        loaded.encounters = 50
        let otherRepository = CoreDataCatchRepository(managedContext: store.context)
        otherRepository.update(loaded)
        XCTAssertTrue(otherRepository.save())

        try store.reopen()
        let reloaded = CoreDataCatchRepository(managedContext: store.context).getAll()
        XCTAssertEqual(reloaded.map { $0.id }, [original.id])
        XCTAssertEqual(reloaded.first?.encounters, 50)
        XCTAssertEqual(CoreDataCatchRepository(managedContext: store.context).get(id: original.id)?.encounters, 50)
    }

    private func fetchRawRows(_ entityName: String) -> [NSManagedObject] {
        return (try? store.context.fetch(NSFetchRequest<NSManagedObject>(entityName: entityName))) ?? []
    }
}
