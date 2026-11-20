import XCTest
@testable import ShinyDex

final class HuntHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var hunts: InMemoryHuntRepository!

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"])
        hunts = InMemoryHuntRepository()
    }

    private func create(_ name: String, _ numbers: [Int]) -> HuntID {
        return CreateHuntHandler(huntRepository: hunts, pokemonRepository: pokemon).handle(CreateHuntCommand(name: name, pokemonNumbers: numbers))
    }

    private func getAllHunts() -> [HuntSummary] {
        return GetHuntsHandler(huntRepository: hunts, pokemonRepository: pokemon).handle(GetHuntsQuery())
    }

    func test_createHunt_marksPokemonAsHunted_andAddsItAfterExistingHunts() {
        _ = create("First", [0])
        _ = create("Second", [2, 1])

        let result = getAllHunts()

        XCTAssertEqual(result.map { $0.name }, ["First", "Second"])
        XCTAssertEqual(result.map { $0.priority }, [0, 1])
        XCTAssertEqual(result[1].members.map { $0.name }, ["Ivysaur", "Venusaur"])
        XCTAssertTrue(pokemon.get(number: 2)!.isBeingHunted)
        XCTAssertFalse(pokemon.get(number: 3)!.isBeingHunted)
    }

    func test_removingTheLastPokemon_deletesTheHunt_andRenumbersTheRest() {
        _ = create("First", [0])
        let middle = create("Middle", [1])
        _ = create("Last", [2])

        RemovePokemonFromHuntHandler(huntRepository: hunts, pokemonRepository: pokemon).handle(RemovePokemonFromHuntCommand(huntId: middle, number: 1))

        XCTAssertEqual(getAllHunts().map { $0.name }, ["First", "Last"])
        XCTAssertEqual(getAllHunts().map { $0.priority }, [0, 1])
        XCTAssertFalse(pokemon.get(number: 1)!.isBeingHunted)
    }

    func test_incrementAll_countsAnEncounterForEveryMember() {
        let id = create("Starters", [0, 3])
        SetIncrementHandler(pokemonRepository: pokemon).handle(SetIncrementCommand(number: 3, increment: 3))

        IncrementAllInHuntHandler(huntRepository: hunts, changeEncounters: ChangeEncountersHandler(pokemonRepository: pokemon, odds: OddsService()))
            .handle(IncrementAllInHuntCommand(huntId: id))

        XCTAssertEqual(getAllHunts().first?.members.map { $0.encounters }, [1, 3])
        XCTAssertEqual(getAllHunts().first?.totalEncounters, 4)
    }

    func test_reorderRenameAndCollapse_arePersisted() {
        let first = create("First", [0])
        let second = create("Second", [1])
        let update = UpdateHuntHandler(huntRepository: hunts)

        ReorderHuntsHandler(huntRepository: hunts).handle(ReorderHuntsCommand(orderedIds: [second, first]))
        update.handle(UpdateHuntCommand(huntId: first, change: .rename("Renamed")))
        update.handle(UpdateHuntCommand(huntId: second, change: .setCollapsed(true)))

        XCTAssertEqual(getAllHunts().map { $0.name }, ["Second", "Renamed"])
        XCTAssertEqual(getAllHunts().map { $0.isCollapsed }, [true, false])
    }

    func test_clearHunts_removesEveryHunt_andFreesTheirPokemon() {
        _ = create("First", [0, 1])
        _ = create("Second", [2])

        ClearHuntsHandler(huntRepository: hunts, pokemonRepository: pokemon).handle(ClearHuntsCommand())

        XCTAssertTrue(getAllHunts().isEmpty)
        XCTAssertTrue(pokemon.getAll().allSatisfy { !$0.isBeingHunted })
    }
}
