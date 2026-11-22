import XCTest
import CoreData
@testable import ShinyDex

final class StoreMigrationTests: XCTestCase {
    private let storedHuntId = UUID(uuidString: "3C9E1F70-8A42-4D1B-B6E5-2F8A0C7D9E44")!
    private let catchId = UUID(uuidString: "6F1C2B0A-6D0B-4C55-9B7E-0E3B7C1D2A11")!
    private let journeyId = UUID(uuidString: "0D4F7A52-3E21-4B86-8C1A-5B7D9E2F6C33")!
    private let entryIds = [UUID(uuidString: "A1B2C3D4-0000-4000-8000-000000000001")!, UUID(uuidString: "A1B2C3D4-0000-4000-8000-000000000002")!]
    private let caughtDate = Date(timeIntervalSinceReferenceDate: 760_000_000)
    private let journeyCreatedDate = Date(timeIntervalSinceReferenceDate: 750_000_000)
    private let bingoBoardId = UUID(uuidString: "5E8B2C61-7A3D-4F90-9B14-C2D6E8F0A177")!
    private let activeMovesJson = #"[{"name":"Spore","maxPP":24,"remainingPP":3,"type":"grass"}]"#

    func test_upgradeFromVersion1_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex")
    }

    func test_upgradeFromVersion2_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 2")
    }

    func test_upgradeFromVersion3_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 3")
    }

    func test_upgradeFromVersion4_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 4")
    }

    func test_upgradeFromVersion5_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 5")
    }

    func test_upgradeFromVersion6_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 6")
    }

    func test_upgradeFromVersion7_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 7")
    }

    func test_upgradeFromVersion8_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 8")
    }

    func test_upgradeFromVersion9_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 9")
    }

    func test_upgradeFromVersion10_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 10")
    }

    func test_upgradeFromVersion11_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 11")
    }

    func test_upgradeFromVersion12_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 12")
    }

    func test_reopeningVersion13_keepsAllData() throws {
        try assertUpgradeKeepsData(fromVersion: "ShinyDex 13")
    }

    private func assertUpgradeKeepsData(fromVersion version: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("ShinyDex.sqlite")
        let oldModel = TestStore.loadModel(version: version)

        try seedStore(at: url, model: oldModel)
        let stack = try TestStore.openStack(at: url)
        let context = stack.viewContext

        assertPokemon(in: context, file: file, line: line)
        assertHunts(in: context, oldModel: oldModel, file: file, line: line)
        assertActiveMoves(in: context, file: file, line: line)
        if oldModel.entitiesByName["CatchEntity"] != nil {
            assertCatch(in: context, oldModel: oldModel, file: file, line: line)
        }
        if oldModel.entitiesByName["JourneyEntity"] != nil {
            assertJourney(in: context, file: file, line: line)
        }
        if oldModel.entitiesByName["BingoBoardEntity"] != nil {
            assertBingoBoard(in: context, file: file, line: line)
        }
        assertProgress(in: context, oldModel: oldModel, file: file, line: line)

        try stack.close()
    }

    // MARK: Seeding with the old model

    private func seedStore(at url: URL, model: NSManagedObjectModel) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        insert("PokemonEntity", into: context, values: [
            "name": "Ralts", "number": 279, "encounters": 4321, "caughtDescription": "Caught",
            "caughtBall": "dream", "isBeingHunted": true, "generation": 9, "isShinyCharmActive": true,
            "shinyOdds": 1365, "huntMethod": HuntMethod.Masuda.rawValue, "increment": 3, "game": Games.Scarlet.rawValue,
        ])
        insert("HuntEntity", into: context, values: [
            "id": storedHuntId, "name": "Gardevoir line", "indexes": [279, 280], "priority": 4, "isCollapsed": true,
        ])
        insert("HuntEntity", into: context, values: [
            "name": "Starters", "indexes": [0, 3, 6], "priority": 5, "isCollapsed": false,
        ])
        insert("ActiveMovesEntity", into: context, values: [
            "json": activeMovesJson, "pressureActive": true,
        ])
        insert("CatchEntity", into: context, values: [
            "id": catchId, "number": 279, "caughtBall": "dream", "caughtDate": caughtDate, "encounters": 4321,
            "game": Games.Scarlet.rawValue, "huntMethod": HuntMethod.Masuda.rawValue, "isShinyCharmActive": true,
            "isFailed": true, "evs": "0,0,0,252,4,252", "evolvedFrom": 280,
            "nickname": "Kirlia fan", "gender": Gender.female.rawValue, "nature": Nature.modest.rawValue, "ivs": "31,0,31,31,31,",
            "form": "east", "encounterTotalAtFind": 4000,
        ])
        insert("JourneyEntity", into: context, values: [
            "id": journeyId, "name": "Hoenn favourites", "createdDate": journeyCreatedDate, "priority": 1,
            "entries": #"[{"id":"\#(entryIds[0].uuidString)","number":279,"catchId":"\#(catchId.uuidString)"},{"id":"\#(entryIds[1].uuidString)","number":280}]"#,
        ])

        insert("BingoBoardEntity", into: context, values: [
            "id": bingoBoardId, "name": "Paldea bingo", "createdDate": journeyCreatedDate, "priority": 2, "size": 3,
            "cells": #"[{"number":279,"catchId":"\#(catchId.uuidString)"},{"number":280},{},{},{},{},{},{},{}]"#,
        ])

        insert("EncounterLedgerEntity", into: context, values: [
            "total": 4500, "trackedSince": journeyCreatedDate,
        ])
        insert("DailyEncounterEntity", into: context, values: [
            "day": "2026-11-21", "count": 77, "pokemonCounts": #"{"279":70,"280":7}"#,
        ])
        insert("YearlyGoalEntity", into: context, values: [
            "year": 2026, "target": 25,
        ])

        try context.save()
        try coordinator.remove(store)
    }

    // Writes only the attributes this model version has, so one seed works for every version.
    private func insert(_ entityName: String, into context: NSManagedObjectContext, values: [String: Any]) {
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[entityName] else { return }
        let object = NSManagedObject(entity: entity, insertInto: context)
        for (key, value) in values where entity.attributesByName[key] != nil {
            object.setValue(value, forKey: key)
        }
    }

    // MARK: Reading with the current code

    private func assertPokemon(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let pokemon = CoreDataPokemonRepository(managedContext: context).getAll()
        XCTAssertEqual(pokemon.count, 1, file: file, line: line)
        guard let ralts = pokemon.first else { return }
        XCTAssertEqual(ralts.name, "Ralts", file: file, line: line)
        XCTAssertEqual(ralts.number, 279, file: file, line: line)
        XCTAssertEqual(ralts.encounters, 4321, file: file, line: line)
        XCTAssertEqual(ralts.chain, 0, file: file, line: line)
        XCTAssertEqual(ralts.caughtDescription, "Caught", file: file, line: line)
        XCTAssertEqual(ralts.caughtBall, "dream", file: file, line: line)
        XCTAssertTrue(ralts.isBeingHunted, file: file, line: line)
        XCTAssertEqual(ralts.generation, 9, file: file, line: line)
        XCTAssertTrue(ralts.isShinyCharmActive, file: file, line: line)
        XCTAssertEqual(ralts.shinyOdds, 1365, file: file, line: line)
        XCTAssertEqual(ralts.huntMethod, .Masuda, file: file, line: line)
        XCTAssertEqual(ralts.increment, 3, file: file, line: line)
        XCTAssertEqual(ralts.game, .Scarlet, file: file, line: line)
    }

    private func assertHunts(in context: NSManagedObjectContext, oldModel: NSManagedObjectModel, file: StaticString, line: UInt) {
        let hunts = CoreDataHuntRepository(managedContext: context).getAll().sorted { $0.priority < $1.priority }
        XCTAssertEqual(hunts.count, 2, file: file, line: line)
        guard hunts.count == 2 else { return }
        XCTAssertEqual(hunts[0].name, "Gardevoir line", file: file, line: line)
        XCTAssertEqual(hunts[0].indexes, [279, 280], file: file, line: line)
        XCTAssertEqual(hunts[0].priority, 4, file: file, line: line)
        XCTAssertTrue(hunts[0].isCollapsed, file: file, line: line)
        XCTAssertEqual(hunts[1].name, "Starters", file: file, line: line)
        XCTAssertEqual(hunts[1].indexes, [0, 3, 6], file: file, line: line)
        XCTAssertFalse(hunts[1].isCollapsed, file: file, line: line)

        let storedIds = ((try? context.fetch(NSFetchRequest<NSManagedObject>(entityName: "HuntEntity"))) ?? []).compactMap { $0.value(forKey: "id") as? UUID }
        XCTAssertEqual(storedIds.count, 2, "Every hunt has a stored id after launch", file: file, line: line)
        XCTAssertEqual(Set(storedIds).count, 2, "Hunt ids are unique", file: file, line: line)
        XCTAssertEqual(Set(hunts.map { $0.id }), Set(storedIds), "Loaded hunts use their stored ids", file: file, line: line)
        if oldModel.entitiesByName["HuntEntity"]?.attributesByName["id"] != nil {
            XCTAssertEqual(hunts[0].id, storedHuntId, "An existing stored id is kept", file: file, line: line)
        }
    }

    private func assertActiveMoves(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let activeMoves = CoreDataMoveRepository(managedContext: context).getActiveMoves()
        XCTAssertEqual(activeMoves?.moves.map { $0.name }, ["Spore"], file: file, line: line)
        XCTAssertEqual(activeMoves?.moves.map { $0.maxPP }, [24], file: file, line: line)
        XCTAssertEqual(activeMoves?.moves.map { $0.remainingPP }, [3], file: file, line: line)
        XCTAssertEqual(activeMoves?.moves.map { $0.type }, ["grass"], file: file, line: line)
        XCTAssertEqual(activeMoves?.pressureActive, true, file: file, line: line)
    }

    private func assertCatch(in context: NSManagedObjectContext, oldModel: NSManagedObjectModel, file: StaticString, line: UInt) {
        let catches = CoreDataCatchRepository(managedContext: context).getAll()
        XCTAssertEqual(catches.count, 1, file: file, line: line)
        guard let caught = catches.first else { return }
        let oldAttributes = oldModel.entitiesByName["CatchEntity"]!.attributesByName
        XCTAssertEqual(caught.id, catchId, file: file, line: line)
        XCTAssertEqual(caught.number, 279, file: file, line: line)
        XCTAssertEqual(caught.caughtBall, "dream", file: file, line: line)
        XCTAssertEqual(caught.caughtDate, caughtDate, file: file, line: line)
        XCTAssertEqual(caught.encounters, 4321, file: file, line: line)
        XCTAssertEqual(caught.game, .Scarlet, file: file, line: line)
        XCTAssertEqual(caught.huntMethod, .Masuda, file: file, line: line)
        XCTAssertTrue(caught.isShinyCharmActive, file: file, line: line)
        XCTAssertEqual(caught.isFailed, oldAttributes["isFailed"] != nil, file: file, line: line)
        if oldAttributes["evs"] != nil {
            XCTAssertEqual(caught.evs, EffortValues(encoded: "0,0,0,252,4,252"), file: file, line: line)
            XCTAssertEqual(caught.evolvedFrom, 280, file: file, line: line)
        } else {
            XCTAssertTrue(caught.evs.isEmpty, file: file, line: line)
            XCTAssertNil(caught.evolvedFrom, file: file, line: line)
        }
        if oldAttributes["nickname"] != nil {
            XCTAssertEqual(caught.nickname, "Kirlia fan", file: file, line: line)
            XCTAssertEqual(caught.gender, .female, file: file, line: line)
            XCTAssertEqual(caught.nature, .modest, file: file, line: line)
            XCTAssertEqual(caught.ivs, IndividualValues(encoded: "31,0,31,31,31,"), file: file, line: line)
        } else {
            XCTAssertNil(caught.nickname, file: file, line: line)
            XCTAssertNil(caught.gender, file: file, line: line)
            XCTAssertNil(caught.nature, file: file, line: line)
            XCTAssertTrue(caught.ivs.isEmpty, file: file, line: line)
        }
        XCTAssertEqual(caught.formId, oldAttributes["form"] != nil ? "east" : nil, file: file, line: line)
        XCTAssertEqual(caught.encounterTotalAtFind, oldAttributes["encounterTotalAtFind"] != nil ? 4000 : nil, file: file, line: line)
    }

    private func assertProgress(in context: NSManagedObjectContext, oldModel: NSManagedObjectModel, file: StaticString, line: UInt) {
        let ledger = CoreDataEncounterLedgerRepository(managedContext: context).get()
        let goals = CoreDataYearlyGoalRepository(managedContext: context).getAll()
        if oldModel.entitiesByName["EncounterLedgerEntity"] != nil {
            XCTAssertEqual(ledger?.total, 4500, file: file, line: line)
            XCTAssertEqual(ledger?.trackedSince, journeyCreatedDate, file: file, line: line)
            XCTAssertEqual(goals, [YearlyGoal(year: 2026, target: 25)], file: file, line: line)
        } else {
            XCTAssertNil(ledger, "Streaks start untracked after an upgrade", file: file, line: line)
            XCTAssertEqual(goals, [], file: file, line: line)
        }
        let days = CoreDataDailyEncountersRepository(managedContext: context).getAll()
        let dayEntity = oldModel.entitiesByName["DailyEncounterEntity"]
        let expectedCountsByPokemon = dayEntity?.attributesByName["pokemonCounts"] != nil ? [279: 70, 280: 7] : [:]
        let expectedDays = dayEntity != nil ? [DailyEncounters(day: EncounterDay(year: 2026, month: 11, day: 21), count: 77, countsByPokemon: expectedCountsByPokemon)] : []
        XCTAssertEqual(days, expectedDays, file: file, line: line)
    }

    private func assertJourney(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let journeys = CoreDataJourneyRepository(managedContext: context).getAll()
        XCTAssertEqual(journeys.count, 1, file: file, line: line)
        guard let journey = journeys.first else { return }
        XCTAssertEqual(journey.id, journeyId, file: file, line: line)
        XCTAssertEqual(journey.name, "Hoenn favourites", file: file, line: line)
        XCTAssertEqual(journey.createdDate, journeyCreatedDate, file: file, line: line)
        XCTAssertEqual(journey.priority, 1, file: file, line: line)
        XCTAssertEqual(journey.entries.map { $0.id }, entryIds, file: file, line: line)
        XCTAssertEqual(journey.entries.map { $0.number }, [279, 280], file: file, line: line)
        XCTAssertEqual(journey.entries.map { $0.catchId }, [catchId, nil], file: file, line: line)
    }

    private func assertBingoBoard(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let boards = CoreDataBingoBoardRepository(managedContext: context).getAll()
        XCTAssertEqual(boards.count, 1, file: file, line: line)
        guard let board = boards.first else { return }
        XCTAssertEqual(board.id, bingoBoardId, file: file, line: line)
        XCTAssertEqual(board.name, "Paldea bingo", file: file, line: line)
        XCTAssertEqual(board.priority, 2, file: file, line: line)
        XCTAssertEqual(board.size, .three, file: file, line: line)
        XCTAssertEqual(board.cells.prefix(3).map { $0.number }, [279, 280, nil], file: file, line: line)
        XCTAssertEqual(board.cells.prefix(3).map { $0.catchId }, [catchId, nil, nil], file: file, line: line)
    }
}
