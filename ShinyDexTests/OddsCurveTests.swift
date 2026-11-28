import XCTest
@testable import ShinyDex

final class OddsCurveTests: XCTestCase {
    fileprivate let calculator = ShinyChanceCalculator(odds: OddsService(), probability: ProbabilityService())
    fileprivate let fullOdds = HuntConfiguration(game: .Scarlet, generation: 9, huntMethod: .Encounters, isShinyCharmActive: false)
    fileprivate let radar = HuntConfiguration(game: .Platinum, generation: 4, huntMethod: .Pokeradar, isShinyCharmActive: false)

    func test_milestones_areTheFirstEncounterReachingEachChance() {
        let curve = OddsCurve(encounters: 3000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.milestones.map { $0.encounters }, [2839, 9431, 18861])
        XCTAssertEqual(curve.milestones.map { $0.chance }, [50, 90, 99])
    }

    func test_current_matchesTheChanceSoFar() {
        let curve = OddsCurve(encounters: 3000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.current.encounters, 3000)
        XCTAssertEqual(curve.current.chance, calculator.calculateChance(encounters: 3000, chain: 0, configuration: fullOdds), accuracy: 0.0001)
    }

    func test_points_startAtZero_riseSteadily_andRunPastTheLastMilestone() {
        let curve = OddsCurve(encounters: 100, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.points.first, OddsCurve.Point(encounters: 0, chance: 0))
        XCTAssertEqual(curve.points.count, OddsCurve.sampleCount + 1)
        XCTAssertGreaterThan(curve.lastEncounters, 18861)
        XCTAssertTrue(zip(curve.points, curve.points.dropFirst()).allSatisfy { $0.chance <= $1.chance })
    }

    func test_points_runPastTheCurrentCount_whenAHuntHasGoneBeyondEveryMilestone() {
        let curve = OddsCurve(encounters: 40000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertGreaterThan(curve.lastEncounters, 40000)
    }

    func test_chainHunts_assumeTheChainKeepsGrowing_soMilestonesComeSoonerThanAtBaseOdds() {
        let base = OddsCurve(encounters: 0, chain: 0, configuration: HuntConfiguration(game: .Platinum, generation: 4, huntMethod: .Encounters, isShinyCharmActive: false), calculator: calculator)
        let chained = OddsCurve(encounters: 40, chain: 40, configuration: radar, calculator: calculator)

        XCTAssertEqual(chained.current.chance, calculator.calculateChance(encounters: 40, chain: 40, configuration: radar), accuracy: 0.0001)
        XCTAssertLessThan(chained.milestones[0].encounters, base.milestones[0].encounters)
    }
}

final class HuntPaceTests: XCTestCase {
    fileprivate let calendar = Calendar(identifier: .gregorian)
    fileprivate let today = EncounterDay(year: 2026, month: 11, day: 28)

    func test_pace_averagesTheDaysThisPokemonWasHunted_inTheLastTwoWeeks() {
        let days = [
            DailyEncounters(day: today, count: 600, countsByPokemon: [1: 400, 2: 200]),
            DailyEncounters(day: today.adding(days: -3, calendar: calendar), count: 900, countsByPokemon: [1: 900]),
            DailyEncounters(day: today.adding(days: -5, calendar: calendar), count: 300, countsByPokemon: [2: 300]),
            DailyEncounters(day: today.adding(days: -14, calendar: calendar), count: 5000, countsByPokemon: [1: 5000])
        ]

        let pace = HuntPace(number: 1, dailyEncounters: days, today: today, calendar: calendar)

        XCTAssertEqual(pace?.encountersPerDay, 650)
        XCTAssertEqual(pace?.activeDays, 2)
    }

    func test_pace_isNil_withoutRecentEncountersForThatPokemon() {
        let days = [DailyEncounters(day: today, count: 500, countsByPokemon: [2: 500])]

        XCTAssertNil(HuntPace(number: 1, dailyEncounters: days, today: today, calendar: calendar))
    }

    func test_estimateDays_roundsUp_andIsNilOnceReached() {
        let pace = HuntPace(number: 1, dailyEncounters: [DailyEncounters(day: today, count: 500, countsByPokemon: [1: 500])], today: today, calendar: calendar)

        XCTAssertEqual(pace?.estimateDays(toCover: 1001), 3)
        XCTAssertEqual(pace?.estimateDays(toCover: 500), 1)
        XCTAssertNil(pace?.estimateDays(toCover: 0))
    }

    func test_forecast_countsDaysToFullOdds_butNotForChainHunts() {
        let pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur"])
        for (number, method, game) in [(0, HuntMethod.Encounters, Games.Scarlet), (1, HuntMethod.Pokeradar, Games.Platinum)] {
            let hunted = pokemon.get(number: number)!
            hunted.huntConfiguration = HuntConfiguration(game: game, generation: GamesList.games[game]!.generation, huntMethod: method, isShinyCharmActive: false)
            hunted.encounters = 1096
            pokemon.save(hunted)
        }
        let days = InMemoryDailyEncountersRepository()
        days.save(DailyEncounters(day: today, count: 1000, countsByPokemon: [0: 500, 1: 500]))
        let handler = GetHuntForecastHandler(pokemonRepository: pokemon, dailyEncountersRepository: days, odds: OddsService(), calendar: calendar,
                                             makeCurrentDate: { self.today.makeDate(in: self.calendar)! })

        XCTAssertEqual(handler.handle(GetHuntForecastQuery(number: 0)), HuntForecast(encountersPerDay: 500, activeDays: 1, daysToOdds: 6))
        XCTAssertNil(handler.handle(GetHuntForecastQuery(number: 1))?.daysToOdds)
    }
}
