import XCTest
import CoreData
@testable import ShinyDex

// Builds a store with each shipped model version, then opens it the way the app does to prove an upgrade keeps every record.
final class StoreMigrationTests: XCTestCase {
    private let catchId = UUID(uuidString: "6F1C2B0A-6D0B-4C55-9B7E-0E3B7C1D2A11")!
    private let journeyId = UUID(uuidString: "0D4F7A52-3E21-4B86-8C1A-5B7D9E2F6C33")!
    private let entryIds = [UUID(uuidString: "A1B2C3D4-0000-4000-8000-000000000001")!, UUID(uuidString: "A1B2C3D4-0000-4000-8000-000000000002")!]
    private let caughtDate = Date(timeIntervalSinceReferenceDate: 760_000_000)
    private let journeyCreatedDate = Date(timeIntervalSinceReferenceDate: 750_000_000)
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

    private func assertUpgradeKeepsData(fromVersion version: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("ShinyDex.sqlite")
        let oldModel = TestStore.model(version: version)

        try seedStore(at: url, model: oldModel)
        let container = try TestStore.openContainer(at: url)
        let context = container.viewContext

        assertPokemon(in: context, file: file, line: line)
        assertHunt(in: context, file: file, line: line)
        assertActiveMoves(in: context, file: file, line: line)
        if oldModel.entitiesByName["CatchEntity"] != nil {
            assertCatch(in: context, oldModel: oldModel, file: file, line: line)
        }
        if oldModel.entitiesByName["JourneyEntity"] != nil {
            assertJourney(in: context, file: file, line: line)
        }

        for store in container.persistentStoreCoordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }
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
            "name": "Gardevoir line", "indexes": [279, 280], "priority": 4, "isCollapsed": true,
        ])
        insert("ActiveMovesEntity", into: context, values: [
            "json": activeMovesJson, "pressureActive": true,
        ])
        insert("CatchEntity", into: context, values: [
            "id": catchId, "number": 279, "caughtBall": "dream", "caughtDate": caughtDate, "encounters": 4321,
            "game": Games.Scarlet.rawValue, "huntMethod": HuntMethod.Masuda.rawValue, "isShinyCharmActive": true,
            "isFailed": true, "evs": "0,0,0,252,4,252", "evolvedFrom": 280,
        ])
        insert("JourneyEntity", into: context, values: [
            "id": journeyId, "name": "Hoenn favourites", "createdDate": journeyCreatedDate, "priority": 1,
            "entries": #"[{"id":"\#(entryIds[0].uuidString)","number":279,"catchId":"\#(catchId.uuidString)"},{"id":"\#(entryIds[1].uuidString)","number":280}]"#,
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
        let pokemon = PokemonRepository(managedContext: context).getAll().map { Pokemon(pokemonEntity: $0) }
        XCTAssertEqual(pokemon.count, 1, file: file, line: line)
        guard let ralts = pokemon.first else { return }
        XCTAssertEqual(ralts.name, "Ralts", file: file, line: line)
        XCTAssertEqual(ralts.number, 279, file: file, line: line)
        XCTAssertEqual(ralts.encounters, 4321, file: file, line: line)
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

    private func assertHunt(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let hunts = HuntRepository(managedContext: context).getAll().map { Hunt(huntEntity: $0) }
        XCTAssertEqual(hunts.count, 1, file: file, line: line)
        guard let hunt = hunts.first else { return }
        XCTAssertEqual(hunt.name, "Gardevoir line", file: file, line: line)
        XCTAssertEqual(hunt.indexes, [279, 280], file: file, line: line)
        XCTAssertEqual(hunt.priority, 4, file: file, line: line)
        XCTAssertTrue(hunt.isCollapsed, file: file, line: line)
    }

    private func assertActiveMoves(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let activeMoves = MoveRepository(managedContext: context).getAll().map { ActiveMoves(moveEntity: $0) }
        XCTAssertEqual(activeMoves.count, 1, file: file, line: line)
        XCTAssertEqual(activeMoves.first?.json, activeMovesJson, file: file, line: line)
        XCTAssertEqual(activeMoves.first?.pressureActive, true, file: file, line: line)
    }

    private func assertCatch(in context: NSManagedObjectContext, oldModel: NSManagedObjectModel, file: StaticString, line: UInt) {
        let catches = CatchRepository(managedContext: context).getAll().map { Catch(catchEntity: $0) }
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
    }

    private func assertJourney(in context: NSManagedObjectContext, file: StaticString, line: UInt) {
        let journeys = JourneyRepository(managedContext: context).getAll().map { Journey(journeyEntity: $0) }
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
}
