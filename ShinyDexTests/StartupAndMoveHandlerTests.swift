import XCTest
@testable import ShinyDex

final class StartupAndMoveHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var moves: InMemoryMoveRepository!
    private var keyValueStore: InMemoryKeyValueStore!
    private var resources: StubResourceLoader!

    override func setUp() {
        pokemon = InMemoryPokemonRepository()
        catches = InMemoryCatchRepository()
        moves = InMemoryMoveRepository()
        keyValueStore = InMemoryKeyValueStore()
        resources = StubResourceLoader()
        resources.textResources["allGens"] = ["Bulbasaur", "Ivysaur", "Venusaur"]
        resources.dataResources["initialActiveMoves.json"] = Data(#"[{"name":"None","maxPP":35,"remainingPP":35,"type":"Normal"}]"#.utf8)
    }

    private func prepare() {
        PrepareDataHandler(pokemonRepository: pokemon, catchRepository: catches, moveRepository: moves, resourceLoader: resources, keyValueStore: keyValueStore)
            .handle(PrepareDataCommand())
    }

    func test_firstLaunch_fillsPokemonAndMoves() {
        prepare()

        XCTAssertEqual(pokemon.getAll().map { $0.name }, ["Bulbasaur", "Ivysaur", "Venusaur"])
        XCTAssertEqual(moves.getActiveMoves()?.moves.map { $0.name }, ["None"])
    }

    func test_laterLaunch_addsNewPokemon_andBackfillsOldCatchesOnce() {
        pokemon.insert(Pokemon(newlyAddedNamed: "Bulbasaur", number: 0))
        let caughtBeforeHistory = Pokemon(newlyAddedNamed: "Ivysaur", number: 1)
        caughtBeforeHistory.caughtBall = "dusk"
        pokemon.insert(caughtBeforeHistory)

        prepare()
        prepare()

        XCTAssertEqual(pokemon.getAll().count, 3)
        XCTAssertEqual(catches.getAll().map { $0.number }, [1])
        XCTAssertEqual(catches.getAll().first?.caughtBall, "dusk")
        XCTAssertTrue(keyValueStore.bool(forKey: "didBackfillCatches_v1"))
        XCTAssertNil(moves.getActiveMoves(), "Moves are only filled on first launch")
    }

    func test_activeMoves_saveAndLoadAsSlots() {
        let set = ActiveMoveSet(slots: [MoveSlot(name: "Spore", maxPP: 24, remainingPP: 20, type: "Grass")], pressureActive: true)

        SaveActiveMovesHandler(moveRepository: moves).handle(SaveActiveMovesCommand(moves: set))

        XCTAssertEqual(GetActiveMovesHandler(moveRepository: moves).handle(GetActiveMovesQuery()), set)
    }

    func test_moveOptions_areSortedAndNamedForDisplay() {
        resources.dataResources["moves.json"] = Data(#"""
        [{"id":2,"identifier":"vine-whip","generation_id":1,"type_id":12,"power":45,"pp":25,"accuracy":100,"priority":0,"target_id":10,"damage_class_id":2},
         {"id":1,"identifier":"absorb","generation_id":1,"type_id":12,"power":20,"pp":25,"accuracy":100,"priority":0,"target_id":10,"damage_class_id":3}]
        """#.utf8)

        let options = GetMoveOptionsHandler(resourceLoader: resources).handle(GetMoveOptionsQuery())

        XCTAssertEqual(options.map { $0.name }, ["Absorb", "Vine whip"])
        XCTAssertEqual(options.first?.pp, 25)
    }
}
