import XCTest
@testable import ShinyDex

final class LocationsOverviewTests: XCTestCase {
    private let pichu = 3, pikachu = 4

    private func makeHandler(locations: [Games: [Int: [EncounterLocation]]], availability: [Games: GameAvailability.GameData]) -> GetLocationsOverviewHandler {
        let pokemon = InMemoryPokemonRepository(names: ["A", "B", "C", "Pichu", "Pikachu"])
        let gameAvailability = GameAvailability(dataByGame: availability)
        let getLocations = GetPokemonLocationsHandler(pokemonRepository: pokemon, locations: PokemonLocations(locationsByGame: locations), availability: gameAvailability,
                                                      evolutions: Evolutions(evolvesFrom: [-1, -1, -1, -1, 3]))
        return GetLocationsOverviewHandler(pokemonRepository: pokemon, getPokemonLocations: getLocations, getGameChoices: GetGameChoicesHandler(availability: gameAvailability))
    }

    private func makeEncounter(area: String, rate: Int, staticRate: Int? = nil, isShinyLocked: Bool = false) -> EncounterLocation {
        return EncounterLocation(area: area, method: "Grass or cave", minimumLevel: 3, maximumLevel: 5, ratePercent: rate, condition: nil,
                                 abilityBoosts: staticRate.map { [EncounterLocation.AbilityBoost(ability: .staticAbility, ratePercent: $0)] } ?? [],
                                 isShinyLocked: isShinyLocked)
    }

    func test_bestGames_rankGamesByTheirBestRate_includingTechniques() throws {
        let handler = makeHandler(locations: [
            .Red: [pikachu: [makeEncounter(area: "Viridian Forest", rate: 5), makeEncounter(area: "Power Plant", rate: 25)]],
            .Gold: [pikachu: [makeEncounter(area: "Route 2", rate: 10, staticRate: 50)]],
            .Ruby: [pikachu: [makeEncounter(area: "Safari Zone", rate: 30)]]
        ], availability: [:])
        let overview = try XCTUnwrap(handler.handle(GetLocationsOverviewQuery(number: pikachu)))

        XCTAssertEqual(overview.pokemonName, "Pikachu")
        XCTAssertEqual(overview.bestGames.prefix(3).map { $0.game }, [.Gold, .Ruby, .Red])
        let gold = try XCTUnwrap(overview.games.first { $0.game == .Gold }?.bestPlace)
        XCTAssertEqual(gold.area, "Route 2")
        XCTAssertEqual(gold.technique, LocationsOverview.Technique(kind: .staticAbility, ratePercent: 50))
        XCTAssertEqual(overview.games.first { $0.game == .Red }?.bestPlace?.area, "Power Plant")
        XCTAssertEqual(overview.games.first { $0.game == .Gold }?.generation, 2)
    }

    func test_bestGames_rankRepeatableEncountersAboveOneTimeGifts() throws {
        let handler = makeHandler(locations: [
            .Yellow: [pikachu: [makeEncounter(area: "Pallet Town", rate: 0)]],
            .Red: [pikachu: [makeEncounter(area: "Viridian Forest", rate: 5)]]
        ], availability: [:])
        let overview = try XCTUnwrap(handler.handle(GetLocationsOverviewQuery(number: pikachu)))

        XCTAssertEqual(overview.bestGames.map { $0.game }, [.Red, .Yellow])
    }

    func test_smallTechniqueGains_areLeftOut() throws {
        let handler = makeHandler(locations: [.Gold: [pikachu: [makeEncounter(area: "Route 2", rate: 30, staticRate: 33)]]], availability: [:])
        let overview = try XCTUnwrap(handler.handle(GetLocationsOverviewQuery(number: pikachu)))

        XCTAssertNil(overview.games.first { $0.game == .Gold }?.bestPlace?.technique)
    }

    func test_shinyLockedEncounters_areNeverABestPlace() throws {
        let handler = makeHandler(locations: [.Gold: [pikachu: [makeEncounter(area: "Violet City", rate: 0, isShinyLocked: true)]]], availability: [:])
        let overview = try XCTUnwrap(handler.handle(GetLocationsOverviewQuery(number: pikachu)))

        XCTAssertNil(overview.games.first { $0.game == .Gold }?.bestPlace)
        XCTAssertFalse(overview.bestGames.contains { $0.game == .Gold })
    }

    func test_gamesWithoutAPlace_explainWhy() throws {
        let handler = makeHandler(locations: [.Red: [pichu: [makeEncounter(area: "Route 1", rate: 10)]], .Blue: [:]],
                                  availability: [.Blue: GameAvailability.GameData(catchable: [], tradeOnly: [pikachu], isApproximate: false),
                                                 .Yellow: GameAvailability.GameData(catchable: [], tradeOnly: [], isApproximate: false)])
        let overview = try XCTUnwrap(handler.handle(GetLocationsOverviewQuery(number: pikachu)))

        XCTAssertEqual(overview.games.first { $0.game == .Red }?.guidance, .evolveFrom(NamedPokemon(number: pichu, name: "Pichu")))
        XCTAssertEqual(overview.games.first { $0.game == .Blue }?.guidance, .tradeOnly)
        XCTAssertFalse(overview.games.contains { $0.game == .Yellow })
        XCTAssertEqual(overview.games.first { $0.game == .Gold }?.hasLocationData, false)
        XCTAssertTrue(overview.bestGames.isEmpty)
    }
}
