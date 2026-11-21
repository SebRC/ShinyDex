import XCTest
@testable import ShinyDex

final class PokemonLocationsTests: XCTestCase {
    private let charmander = 0, charmeleon = 1, charizard = 2, pichu = 3, pikachu = 4

    private func makeLocations() -> PokemonLocations {
        let resources = StubResourceLoader()
        resources.dataResources["pokemonLocations.json"] = Data("""
        {"strings":["Route 10","Grass or cave","","Route 3","During the day","Viridian Forest"],
         "games":{"Red":{"2":[[0,1,20,24,25,2]],"5":[[5,1,3,5,5,2],[3,1,4,6,10,4,6,40,62,0,8,30,55]]},"Not a game":{"1":[[0,1,1,1,1,2]]}}}
        """.utf8)
        return PokemonLocationsLoader.load(from: resources)
    }

    private func makeHandler(availability: GameAvailability = GameAvailability()) -> GetPokemonLocationsHandler {
        let pokemon = InMemoryPokemonRepository(names: ["Charmander", "Charmeleon", "Charizard", "Pichu", "Pikachu"])
        return GetPokemonLocationsHandler(pokemonRepository: pokemon, locations: makeLocations(), availability: availability,
                                          evolutions: Evolutions(evolvesFrom: [-1, 0, 1, -1, 3]))
    }

    func test_loader_mapsNationalNumbers_andConditions() {
        let locations = makeLocations()

        XCTAssertEqual(locations.findLocations(of: charmeleon, in: .Red), [
            EncounterLocation(area: "Route 10", method: "Grass or cave", minimumLevel: 20, maximumLevel: 24, ratePercent: 25, condition: nil)
        ])
        let route3 = locations.findLocations(of: pikachu, in: .Red).last
        XCTAssertEqual(route3?.condition, "During the day")
        XCTAssertEqual(route3?.repelTrick, EncounterLocation.RepelTrick(leadLevel: 6, ratePercent: 40, withPressureRatePercent: 55))
        XCTAssertEqual(route3?.keenEyeBoost, EncounterLocation.KeenEyeBoost(leadLevel: 8, ratePercent: 30))
        XCTAssertEqual(route3?.abilityBoosts, [EncounterLocation.AbilityBoost(ability: .staticAbility, ratePercent: 62)])
        XCTAssertNil(locations.findLocations(of: pikachu, in: .Red).first?.repelTrick)
        XCTAssertTrue(locations.hasData(for: .Red))
        XCTAssertFalse(locations.hasData(for: .Gold))
    }

    func test_loader_readsEncounterSpeed_withTheRepelTrick_andSpeedAbilities() {
        let resources = StubResourceLoader()
        resources.dataResources["pokemonLocations.json"] = Data("""
        {"strings":["Kanto Power Plant","Grass or cave",""],"games":{"Emerald":{"25":[[0,1,20,24,25,2,24,40,0,0,0,0,55,0,25,60,1]]},"Red":{"25":[[0,1,20,24,25,2,24,40]]}}}
        """.utf8)
        let locations = PokemonLocationsLoader.load(from: resources)
        let emerald = locations.findLocations(of: 24, in: .Emerald).first

        XCTAssertEqual(emerald?.repelTrick, EncounterLocation.RepelTrick(leadLevel: 24, ratePercent: 40, withPressureRatePercent: 55, encounterPercent: 25, withPressureEncounterPercent: 60))
        XCTAssertEqual(emerald?.isSpedUpByAbilities, true)
        XCTAssertEqual(locations.findLocations(of: 24, in: .Red).first?.repelTrick?.encounterPercent, 100)
        XCTAssertEqual(locations.findLocations(of: 24, in: .Red).first?.isSpedUpByAbilities, false)
    }

    func test_places_areSortedByTheirBestRate() throws {
        let result = try XCTUnwrap(makeHandler().handle(GetPokemonLocationsQuery(number: pikachu, game: .Red)))

        XCTAssertEqual(result.places.map { $0.area }, ["Route 3", "Viridian Forest"])
        XCTAssertEqual(result.places.map { $0.bestRatePercent }, [10, 5])
        XCTAssertEqual(result.places.first?.encounters.first?.repelTrick, PokemonLocationsResult.Encounter.RepelTrick(leadLevel: 6, ratePercent: 40, withPressureRatePercent: 55))
        XCTAssertEqual(result.places.first?.encounters.first?.keenEyeBoost, PokemonLocationsResult.Encounter.KeenEyeBoost(leadLevel: 8, ratePercent: 30))
        XCTAssertEqual(result.guidance, .none)
        XCTAssertTrue(result.hasLocationData)
    }

    func test_withoutLocations_suggestsEvolvingFromAnAncestorFoundInTheGame() throws {
        let result = try XCTUnwrap(makeHandler().handle(GetPokemonLocationsQuery(number: charizard, game: .Red)))

        XCTAssertTrue(result.places.isEmpty)
        XCTAssertEqual(result.guidance, .evolveFrom(NamedPokemon(number: charmeleon, name: "Charmeleon")))
    }

    func test_withoutLocations_suggestsBreedingFromADescendantFoundInTheGame() throws {
        let result = try XCTUnwrap(makeHandler().handle(GetPokemonLocationsQuery(number: pichu, game: .Red)))

        XCTAssertEqual(result.guidance, .breedFrom(NamedPokemon(number: pikachu, name: "Pikachu")))
    }

    func test_oneTimeEncounters_sortFirst_withoutARate() throws {
        let resources = StubResourceLoader()
        resources.dataResources["pokemonLocations.json"] = Data("""
        {"strings":["Route 1","Grass or cave","","Lab","Gift"],"games":{"Red":{"5":[[0,1,3,5,30,2],[3,4,5,5,0,2]]}}}
        """.utf8)
        let handler = GetPokemonLocationsHandler(pokemonRepository: InMemoryPokemonRepository(names: ["A", "B", "C", "D", "Pikachu"]),
                                                 locations: PokemonLocationsLoader.load(from: resources), availability: GameAvailability(), evolutions: Evolutions(evolvesFrom: []))
        let result = try XCTUnwrap(handler.handle(GetPokemonLocationsQuery(number: pikachu, game: .Red)))

        XCTAssertEqual(result.places.map { $0.area }, ["Lab", "Route 1"])
        XCTAssertEqual(result.places.first?.encounters.first?.isOneTime, true)
        XCTAssertEqual(result.places.last?.encounters.first?.isOneTime, false)
    }

    func test_shinyLockedEncounters_sortLast_andDoNotCountAsAPlacesBestRate() throws {
        let resources = StubResourceLoader()
        resources.dataResources["pokemonLocations.json"] = Data("""
        {"strings":["Violet City","In-game trade","","Route 1","Grass or cave"],
         "games":{"Gold":{"5":[[0,1,0,0,0,2,0,0,0,0,0,0,0,1],[3,4,3,5,10,2,0,0,0,0,0,0,0,0]]}}}
        """.utf8)
        let locations = PokemonLocationsLoader.load(from: resources)
        let handler = GetPokemonLocationsHandler(pokemonRepository: InMemoryPokemonRepository(names: ["A", "B", "C", "D", "Onix"]),
                                                 locations: locations, availability: GameAvailability(), evolutions: Evolutions(evolvesFrom: []))
        let result = try XCTUnwrap(handler.handle(GetPokemonLocationsQuery(number: pikachu, game: .Gold)))

        XCTAssertEqual(locations.findLocations(of: pikachu, in: .Gold).first?.isShinyLocked, true)
        XCTAssertEqual(result.places.map { $0.area }, ["Route 1", "Violet City"])
        XCTAssertEqual(result.places.last?.encounters.first?.isShinyLocked, true)
    }

    func test_tradeOnlyAndUnavailablePokemon_sayWhy() throws {
        let availability = GameAvailability(dataByGame: [.Red: GameAvailability.GameData(catchable: [], tradeOnly: [charizard], isApproximate: false)])

        XCTAssertEqual(makeHandler(availability: availability).handle(GetPokemonLocationsQuery(number: charizard, game: .Red))?.guidance, .tradeOnly)
        XCTAssertEqual(makeHandler(availability: availability).handle(GetPokemonLocationsQuery(number: charmander, game: .Red))?.guidance, .unavailable)
    }

    func test_gamesWithoutData_saySo() throws {
        let result = try XCTUnwrap(makeHandler().handle(GetPokemonLocationsQuery(number: pikachu, game: .Scarlet)))

        XCTAssertFalse(result.hasLocationData)
        XCTAssertTrue(result.places.isEmpty)
    }

    func test_bundledData_knowsWhereToFindPikachuAndMagikarpInRed() {
        let locations = PokemonLocationsLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppContainer.self)))

        XCTAssertTrue(locations.findLocations(of: 24, in: .Red).contains { $0.area == "Viridian Forest" })
        XCTAssertTrue(locations.findLocations(of: 128, in: .Red).contains { $0.method == "Old Rod" })
        XCTAssertEqual(locations.findLocations(of: 24, in: .Red).first { $0.area == "Kanto Power Plant" }?.repelTrick, EncounterLocation.RepelTrick(leadLevel: 24, ratePercent: 40, encounterPercent: 25))
        XCTAssertEqual(locations.findLocations(of: 24, in: .Emerald).first { $0.area == "Safari Zone (SE)" }?.isSpedUpByAbilities, true)
        XCTAssertEqual(locations.findLocations(of: 80, in: .Emerald).first { $0.area == "New Mauville" }?.abilityBoosts.first?.ability, .magnetPull)
        XCTAssertTrue(locations.findLocations(of: 80, in: .Ruby).allSatisfy { $0.abilityBoosts.isEmpty && $0.keenEyeBoost == nil }, "Field abilities only work in Emerald in Gen 3")
        XCTAssertEqual(locations.findLocations(of: 20, in: .Gold).first { $0.method == "Gift" }?.isShinyLocked, true, "Kenya the Spearow")
        XCTAssertEqual(locations.findLocations(of: 94, in: .SoulSilver).first { $0.method == "In-game trade" }?.isShinyLocked, true, "Violet City Onix")
        XCTAssertEqual(locations.findLocations(of: 24, in: .SoulSilver).first { $0.area == "Viridian Forest" }?.isShinyLocked, false)
        XCTAssertTrue(locations.hasData(for: .Sword))
        XCTAssertFalse(locations.hasData(for: .Scarlet))
    }
}
