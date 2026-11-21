import XCTest
import CoreData
@testable import ShinyDex

final class HuntChainTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private let calculator = ShinyChanceCalculator(odds: OddsService(), probability: ProbabilityService())

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur"])
    }

    private func setMethod(_ huntMethod: HuntMethod, game: Games, of number: Int) {
        let hunted = pokemon.get(number: number)!
        hunted.huntConfiguration = HuntConfiguration(game: game, generation: GamesList.games[game]!.generation, huntMethod: huntMethod, isShinyCharmActive: false)
        pokemon.save(hunted)
    }

    private func changeEncounters(_ change: ChangeEncountersCommand.Change, of number: Int = 0) {
        ChangeEncountersHandler(pokemonRepository: pokemon, catchRepository: InMemoryCatchRepository(), ledgerRepository: InMemoryEncounterLedgerRepository(), dailyEncountersRepository: InMemoryDailyEncountersRepository(), odds: OddsService()).handle(ChangeEncountersCommand(number: number, change: change))
    }

    private func changeChain(_ change: ChangeChainCommand.Change, of number: Int = 0) {
        ChangeChainHandler(pokemonRepository: pokemon, odds: OddsService()).handle(ChangeChainCommand(number: number, change: change))
    }

    private func makeDetails(_ number: Int = 0) -> PokemonDetails {
        return GetPokemonDetailsHandler(pokemonRepository: pokemon, catchRepository: InMemoryCatchRepository(), odds: OddsService(), probability: ProbabilityService())
            .handle(GetPokemonDetailsQuery(number: number))!
    }

    // MARK: Counting

    func test_chainAndPatches_areCountedSeparately() {
        setMethod(.Pokeradar, game: .Platinum, of: 0)

        changeChain(.increment)
        changeChain(.increment)
        changeEncounters(.increment)

        let details = makeDetails()
        XCTAssertEqual(details.chain, 2)
        XCTAssertEqual(details.encounters, 1)
        XCTAssertTrue(details.usesChain)
        XCTAssertEqual(details.shinyOdds, PokeradarOddsService().getOdds(chain: 2, generation: 4))
    }

    func test_pokeradarInXAndY_startsAt4096() {
        setMethod(.Pokeradar, game: .X, of: 0)

        XCTAssertEqual(makeDetails().shinyOdds, 4096)
    }

    func test_methodsWithoutAChain_onlyCountEncounters() {
        setMethod(.Masuda, game: .Scarlet, of: 0)

        changeEncounters(.increment)

        XCTAssertEqual(makeDetails().encounters, 1)
        XCTAssertEqual(makeDetails().chain, 0)
        XCTAssertFalse(makeDetails().usesChain)
    }

    func test_shorteningTheChain_stopsAtZero_andLeavesEncountersAlone() {
        setMethod(.ChainFishing, game: .X, of: 0)
        changeEncounters(.set(10))
        changeChain(.increment)

        changeChain(.decrement)
        changeChain(.decrement)

        XCTAssertEqual(makeDetails().chain, 0)
        XCTAssertEqual(makeDetails().encounters, 10)
    }

    func test_breakingTheChain_resetsItAndItsOdds_andKeepsTheEncounters() {
        setMethod(.Pokeradar, game: .Platinum, of: 0)
        changeChain(.set(45))
        changeEncounters(.set(300))
        XCTAssertEqual(makeDetails().shinyOdds, 200)

        changeChain(.breakChain)

        let details = makeDetails()
        XCTAssertEqual(details.chain, 0)
        XCTAssertEqual(details.encounters, 300)
        XCTAssertEqual(details.shinyOdds, 8192)
    }

    // MARK: Chance so far

    func test_chanceSoFar_countsEncountersBeforeTheChainAtBaseOdds() {
        let radar = HuntConfiguration(game: .Platinum, generation: 4, huntMethod: .Pokeradar, isShinyCharmActive: false)
        let noChain = calculator.calculateChance(encounters: 100, chain: 0, configuration: radar)

        XCTAssertEqual(noChain, ProbabilityService().getProbability(encounters: 100, shinyOdds: 8192), accuracy: 0.0001)
        XCTAssertGreaterThan(calculator.calculateChance(encounters: 100, chain: 60, configuration: radar), noChain)
    }

    func test_chanceSoFar_showsFromTheFirstEncounterOfAChain() {
        setMethod(.SosChaining, game: .Sun, of: 0)

        changeChain(.increment)
        changeEncounters(.increment)

        XCTAssertGreaterThan(makeDetails().probability, 0)
    }

    // MARK: Labels

    func test_counterText_namesTheChainAndTheEncountersForEachMethod() {
        let fixture = PokemonFixture()
        fixture.encounters = 120
        fixture.huntMethod = .Pokeradar
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails(chain: 40, usesChain: true)),
                       HuntCounterText(primary: .init(label: "Chain", value: 40), secondary: .init(label: "Patches", value: 120)))

        fixture.huntMethod = .DexNav
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails(chain: 12, usesChain: true)).primary.label, "Search level")
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails(chain: 12, usesChain: true)).secondary?.label, "Encounters")

        fixture.huntMethod = .Encounters
        fixture.game = .LetsGoPikachu
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails(chain: 5, usesChain: true)).primary.label, "Catch combo")

        fixture.game = .Scarlet
        fixture.huntMethod = .Masuda
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails()), HuntCounterText(primary: .init(label: "Eggs", value: 120), secondary: nil))

        fixture.huntMethod = .Encounters
        XCTAssertEqual(HuntCounterText(pokemon: fixture.makeDetails()).primary.label, "Encounters")
    }

    // MARK: Upgrading stored hunts

    func test_upgradingAVersion9Store_givesChainHuntsTheChainTheirOddsUsed() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("ShinyDex.sqlite")
        try seedVersion9Store(at: url, rows: [
            (number: 0, method: .Pokeradar, game: .Platinum, encounters: 55),
            (number: 1, method: .ChainFishing, game: .X, encounters: 12),
            (number: 2, method: .Masuda, game: .Scarlet, encounters: 300)
        ])

        var stack = try TestStore.openStack(at: url)
        let upgraded = CoreDataPokemonRepository(managedContext: stack.viewContext).getAll()
        XCTAssertEqual(upgraded.map { $0.chain }, [40, 12, 0])
        XCTAssertEqual(upgraded.map { $0.encounters }, [55, 12, 300])

        let radar = upgraded[0]
        radar.chain = 5
        CoreDataPokemonRepository(managedContext: stack.viewContext).save(radar)
        try stack.close()
        stack = try TestStore.openStack(at: url)
        XCTAssertEqual(CoreDataPokemonRepository(managedContext: stack.viewContext).get(number: 0)?.chain, 5, "The upgrade only fills in missing chains")
        try stack.close()
    }

    private func seedVersion9Store(at url: URL, rows: [(number: Int, method: HuntMethod, game: Games, encounters: Int)]) throws {
        let model = TestStore.loadModel(version: "ShinyDex 9")
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        for row in rows {
            let entity = NSManagedObject(entity: model.entitiesByName["PokemonEntity"]!, insertInto: context)
            let values: [String: Any] = [
                "name": "Pokémon \(row.number)", "number": row.number, "encounters": row.encounters, "caughtDescription": "Not Caught",
                "caughtBall": "none", "isBeingHunted": false, "generation": GamesList.games[row.game]!.generation, "isShinyCharmActive": false,
                "shinyOdds": 8192, "huntMethod": row.method.rawValue, "increment": 1, "game": row.game.rawValue
            ]
            values.forEach { entity.setValue($0.value, forKey: $0.key) }
        }
        try context.save()
        try coordinator.remove(store)
    }
}
