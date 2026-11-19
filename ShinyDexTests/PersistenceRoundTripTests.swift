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

    private func date(_ day: Int) -> Date {
        return DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "UTC"), year: 2025, month: 3, day: day, hour: 14, minute: 30).date!
    }

    // MARK: Catch

    func test_catch_withEveryFieldSet_survivesSaveAndReload() throws {
        let original = Catch(number: 25, caughtBall: "ultra", game: .Scarlet, huntMethod: .Masuda, encounters: 1234, isShinyCharmActive: true, caughtDate: date(4), isFailed: true)
        original.evs = EffortValues(encoded: "4,252,0,0,0,252")
        original.evolvedFrom = 171
        let repository = CatchRepository(managedContext: store.context)
        repository.insert(catchToInsert: original)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let reloaded = CatchRepository(managedContext: store.context).getAll().map { Catch(catchEntity: $0) }

        XCTAssertEqual(reloaded.count, 1)
        let caught = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(caught.id, original.id)
        XCTAssertEqual(caught.number, 25)
        XCTAssertEqual(caught.caughtBall, "ultra")
        XCTAssertEqual(caught.game, .Scarlet)
        XCTAssertEqual(caught.huntMethod, .Masuda)
        XCTAssertEqual(caught.encounters, 1234)
        XCTAssertTrue(caught.isShinyCharmActive)
        XCTAssertEqual(caught.caughtDate, date(4))
        XCTAssertTrue(caught.isFailed)
        XCTAssertEqual(caught.evs, original.evs)
        XCTAssertEqual(caught.evolvedFrom, 171)
    }

    func test_catch_withOptionalFieldsEmpty_survivesSaveAndReload() throws {
        let original = Catch(number: 1, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil)
        let repository = CatchRepository(managedContext: store.context)
        repository.insert(catchToInsert: original)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let entity = try XCTUnwrap(CatchRepository(managedContext: store.context).getAll().first)
        let caught = Catch(catchEntity: entity)

        XCTAssertNil(entity.value(forKey: "evs"), "Empty EVs are stored as nil")
        XCTAssertEqual(entity.value(forKey: "evolvedFrom") as? Int, -1, "No pre-evolution is stored as -1")
        XCTAssertNil(caught.caughtDate)
        XCTAssertTrue(caught.evs.isEmpty)
        XCTAssertNil(caught.evolvedFrom)
        XCTAssertFalse(caught.isFailed)
    }

    func test_catch_update_andDelete_arePersisted() throws {
        let first = Catch(number: 4, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 10, isShinyCharmActive: false, caughtDate: date(1))
        let second = Catch(number: 7, caughtBall: "great", game: .Red, huntMethod: .Encounters, encounters: 20, isShinyCharmActive: false, caughtDate: date(2))
        let repository = CatchRepository(managedContext: store.context)
        repository.insert(catchToInsert: first)
        repository.insert(catchToInsert: second)
        XCTAssertTrue(repository.save())

        first.encounters = 99
        repository.update(catchToUpdate: first)
        repository.delete(catchToDelete: second)
        XCTAssertTrue(repository.save())

        try store.reopen()
        let reloaded = CatchRepository(managedContext: store.context).getAll().map { Catch(catchEntity: $0) }

        XCTAssertEqual(reloaded.map { $0.id }, [first.id])
        XCTAssertEqual(reloaded.first?.encounters, 99)
    }

    func test_catch_fetchByNumber_returnsOnlyThatSpecies() throws {
        let repository = CatchRepository(managedContext: store.context)
        for number in [1, 4, 4] {
            repository.insert(catchToInsert: Catch(number: number, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil))
        }
        XCTAssertTrue(repository.save())

        try store.reopen()

        XCTAssertEqual(CatchRepository(managedContext: store.context).getAll(number: 4).count, 2)
    }

    // MARK: Hunt

    func test_hunt_survivesSaveAndReload() throws {
        let hunt = Hunt(name: "Starters", pokemon: [], priority: 3)
        hunt.indexes = [0, 3, 6]
        hunt.isCollapsed = true
        HuntRepository(managedContext: store.context).save(hunt: hunt)

        try store.reopen()
        let reloaded = HuntRepository(managedContext: store.context).getAll().map { Hunt(huntEntity: $0) }

        XCTAssertEqual(reloaded.count, 1)
        let stored = try XCTUnwrap(reloaded.first)
        XCTAssertEqual(stored.name, "Starters")
        XCTAssertEqual(stored.indexes, [0, 3, 6])
        XCTAssertEqual(stored.priority, 3)
        XCTAssertTrue(stored.isCollapsed)
    }

    func test_hunt_update_andDelete_arePersisted() throws {
        let kept = Hunt(name: "Kept", pokemon: [], priority: 0)
        let removed = Hunt(name: "Removed", pokemon: [], priority: 1)
        let repository = HuntRepository(managedContext: store.context)
        repository.save(hunt: kept)
        repository.save(hunt: removed)

        kept.name = "Renamed"
        kept.indexes = [150]
        repository.save(hunt: kept)
        repository.delete(hunt: removed)

        try store.reopen()
        let reloaded = HuntRepository(managedContext: store.context).getAll().map { Hunt(huntEntity: $0) }

        XCTAssertEqual(reloaded.map { $0.name }, ["Renamed"])
        XCTAssertEqual(reloaded.first?.indexes, [150])
    }

    // MARK: Journey

    func test_journey_survivesSaveAndReload() throws {
        let journey = Journey(name: "Kanto dream team", priority: 2, numbers: [0, 3, 6])
        let catchId = UUID()
        journey.entries[1].catchId = catchId
        XCTAssertTrue(JourneyRepository(managedContext: store.context).save(journey: journey))

        try store.reopen()
        let reloaded = JourneyRepository(managedContext: store.context).getAll().map { Journey(journeyEntity: $0) }

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
        XCTAssertTrue(JourneyRepository(managedContext: store.context).save(journey: journey))

        try store.reopen()
        let entity = try XCTUnwrap(JourneyRepository(managedContext: store.context).getAll().first)
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
        let repository = JourneyRepository(managedContext: store.context)
        XCTAssertTrue(repository.save(journey: journey))
        repository.delete(journey: journey)

        try store.reopen()

        XCTAssertTrue(JourneyRepository(managedContext: store.context).getAll().isEmpty)
    }

    // MARK: Pokemon

    func test_pokemon_createdWithDefaults_survivesReload() throws {
        PokemonRepository(managedContext: store.context).save(name: "Bulbasaur", number: 0)

        try store.reopen()
        let reloaded = PokemonRepository(managedContext: store.context).getAll().map { Pokemon(pokemonEntity: $0) }

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
    }

    func test_pokemon_changes_surviveReload() throws {
        PokemonRepository(managedContext: store.context).save(name: "Ralts", number: 279)
        try store.reopen()
        let pokemon = try XCTUnwrap(PokemonRepository(managedContext: store.context).getAll().map { Pokemon(pokemonEntity: $0) }.first)
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
        PokemonRepository(managedContext: store.context).save(pokemon: pokemon)

        try store.reopen()
        let reloaded = try XCTUnwrap(PokemonRepository(managedContext: store.context).getAll().map { Pokemon(pokemonEntity: $0) }.first)

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
    }

    func test_pokemon_areReturnedSortedByNumber() throws {
        let repository = PokemonRepository(managedContext: store.context)
        repository.save(name: "Squirtle", number: 6)
        repository.save(name: "Bulbasaur", number: 0)
        repository.save(name: "Charmander", number: 3)

        try store.reopen()

        XCTAssertEqual(PokemonRepository(managedContext: store.context).getAll().map { Pokemon(pokemonEntity: $0).number }, [0, 3, 6])
    }

    // MARK: Active moves

    func test_activeMoves_surviveSaveAndReload() throws {
        let json = #"[{"name":"Spore","maxPP":24,"remainingPP":17,"type":"grass"}]"#
        MoveRepository(managedContext: store.context).save(json: json)

        try store.reopen()
        let activeMoves = try XCTUnwrap(MoveRepository(managedContext: store.context).getAll().map { ActiveMoves(moveEntity: $0) }.first)
        XCTAssertEqual(activeMoves.json, json)
        XCTAssertFalse(activeMoves.pressureActive)

        activeMoves.pressureActive = true
        MoveRepository(managedContext: store.context).save(activeMoves: activeMoves)

        try store.reopen()
        let reloaded = try XCTUnwrap(MoveRepository(managedContext: store.context).getAll().map { ActiveMoves(moveEntity: $0) }.first)
        XCTAssertEqual(reloaded.json, json)
        XCTAssertTrue(reloaded.pressureActive)
    }
}
