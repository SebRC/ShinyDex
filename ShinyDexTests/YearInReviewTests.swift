import XCTest
@testable import ShinyDex

final class YearInReviewTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var goals: InMemoryYearlyGoalRepository!
    private var days: InMemoryDailyEncountersRepository!
    private let bulbasaur = 0, charmander = 1, squirtle = 2
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Charmander", "Squirtle"])
        catches = InMemoryCatchRepository()
        goals = InMemoryYearlyGoalRepository()
        days = InMemoryDailyEncountersRepository()
    }

    private func makeDate(year: Int = 2026, month: Int, day: Int) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: 12).date!
    }

    @discardableResult
    private func logCatch(_ number: Int, encounters: Int, on date: Date?, game: Games = .Red, method: HuntMethod = .Encounters, ball: String = "poke", isFailed: Bool = false) -> Catch {
        let caught = Catch(number: number, caughtBall: ball, game: game, huntMethod: method, encounters: encounters, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed)
        catches.insert(caught)
        return caught
    }

    private func record(_ count: Int, year: Int = 2026, month: Int, day: Int) {
        days.save(DailyEncounters(day: EncounterDay(year: year, month: month, day: day), count: count))
    }

    private func getReview(year: Int? = nil, now: Date? = nil) -> YearInReview {
        let handler = GetYearInReviewHandler(catchRepository: catches, pokemonRepository: pokemon, yearlyGoalRepository: goals, dailyEncountersRepository: days,
                                             calendar: calendar, makeCurrentDate: { now ?? self.makeDate(month: 11, day: 21) })
        return handler.handle(GetYearInReviewQuery(year: year))
    }

    // MARK: Year

    func test_defaultsToTheCurrentYear_whenItHasData() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(year: 2025, month: 3, day: 1))
        logCatch(charmander, encounters: 10, on: makeDate(month: 2, day: 1))

        let review = getReview()

        XCTAssertEqual(review.year, 2026)
        XCTAssertEqual(review.availableYears, [2026, 2025])
    }

    func test_defaultsToTheLatestYearWithData_whenTheCurrentYearHasNone() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(year: 2024, month: 3, day: 1))
        logCatch(charmander, encounters: 10, on: makeDate(year: 2025, month: 3, day: 1))

        XCTAssertEqual(getReview().year, 2025)
    }

    func test_yearsWithOnlyTrackedEncounters_canBeReviewed() {
        record(50, year: 2025, month: 12, day: 30)
        record(0, year: 2024, month: 12, day: 30)

        XCTAssertEqual(getReview().availableYears, [2025])
    }

    func test_onlyCountsCatchesFromTheChosenYear() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(year: 2025, month: 3, day: 1))
        logCatch(charmander, encounters: 10, on: makeDate(month: 2, day: 1))
        logCatch(squirtle, encounters: 10, on: makeDate(month: 4, day: 1), isFailed: true)
        logCatch(squirtle, encounters: 10, on: nil)

        let review = getReview(year: 2026)

        XCTAssertEqual(review.foundCount, 2)
        XCTAssertEqual(review.caughtCount, 1)
        XCTAssertEqual(review.failedCount, 1)
        XCTAssertEqual(review.caughtSpeciesCount, 1)
    }

    // MARK: Encounters

    func test_encounters_sumTheYearsTrackedDays_withTheBusiestMonthAndDay() {
        record(100, year: 2025, month: 12, day: 31)
        record(300, month: 1, day: 5)
        record(200, month: 1, day: 6)
        record(400, month: 2, day: 1)

        let review = getReview(year: 2026)

        XCTAssertEqual(review.trackedEncounters, 900)
        XCTAssertEqual(review.busiestMonth, YearInReview.MonthCount(month: 1, count: 500))
        XCTAssertEqual(review.busiestDay?.encounters, 400)
        XCTAssertEqual(review.busiestDay?.date, DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: 2, day: 1).date)
    }

    func test_encounters_areMissing_forYearsBeforeTracking() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(year: 2025, month: 3, day: 1))
        record(100, month: 11, day: 20)

        let review = getReview(year: 2025)

        XCTAssertNil(review.trackedEncounters)
        XCTAssertNil(review.busiestMonth)
        XCTAssertNil(review.busiestDay)
    }

    func test_trackingStart_isShown_onlyInTheYearItStartedPartway() {
        record(100, month: 11, day: 20)
        record(100, year: 2027, month: 1, day: 3)

        XCTAssertEqual(getReview(year: 2026).encountersTrackedSince, DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: 11, day: 20).date)
        XCTAssertNil(getReview(year: 2027).encountersTrackedSince)
    }

    // MARK: Goal

    func test_goal_comparesTheYearsFinds_withItsTarget() {
        goals.save(YearlyGoal(year: 2026, target: 2))
        logCatch(bulbasaur, encounters: 10, on: makeDate(month: 2, day: 1))
        logCatch(charmander, encounters: 10, on: makeDate(month: 3, day: 1), isFailed: true)

        XCTAssertEqual(getReview(year: 2026).goal, YearInReview.Goal(target: 2, foundCount: 2, isReached: true))
        XCTAssertNil(getReview(year: 2025).goal)
    }

    // MARK: Hunts

    func test_firstAndLatestShiny_followTheCatchDates() {
        logCatch(charmander, encounters: 10, on: makeDate(month: 6, day: 1))
        logCatch(bulbasaur, encounters: 10, on: makeDate(month: 1, day: 3))
        logCatch(squirtle, encounters: 10, on: makeDate(month: 9, day: 9))

        let review = getReview(year: 2026)

        XCTAssertEqual(review.firstShiny?.pokemonName, "Bulbasaur")
        XCTAssertEqual(review.latestShiny?.pokemonName, "Squirtle")
    }

    func test_latestShiny_isLeftOut_whenThereIsOnlyOne() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(month: 1, day: 3))

        XCTAssertNil(getReview(year: 2026).latestShiny)
    }

    func test_luckiestAndToughestHunts_comeFromTheChanceOfFindingSooner() {
        logCatch(bulbasaur, encounters: 120, on: makeDate(month: 1, day: 3))
        logCatch(charmander, encounters: 20_000, on: makeDate(month: 2, day: 3))
        logCatch(squirtle, encounters: 4_000, on: makeDate(month: 3, day: 3))
        logCatch(squirtle, encounters: 5, on: makeDate(month: 4, day: 3), method: .SosChaining)

        let review = getReview(year: 2026)

        XCTAssertEqual(review.luckiestHunt?.caught.pokemonName, "Bulbasaur")
        XCTAssertEqual(review.luckiestHunt?.percentChanceOfFindingSooner ?? 0, Double.getProbability(encounters: 120, odds: 8192), accuracy: 0.000001)
        XCTAssertEqual(review.unluckiestHunt?.caught.pokemonName, "Charmander")
    }

    func test_toughestHunt_isLeftOut_withOnlyOneHuntWithKnownOdds() {
        logCatch(bulbasaur, encounters: 120, on: makeDate(month: 1, day: 3))

        let review = getReview(year: 2026)

        XCTAssertNotNil(review.luckiestHunt)
        XCTAssertNil(review.unluckiestHunt)
    }

    // MARK: Favourites

    func test_bestMonthAndFavourites_comeFromTheYearsCatches() {
        logCatch(bulbasaur, encounters: 10, on: makeDate(month: 3, day: 1), game: .Scarlet, ball: "ultra")
        logCatch(charmander, encounters: 10, on: makeDate(month: 3, day: 9), game: .Scarlet, method: .Masuda, ball: "ultra")
        logCatch(squirtle, encounters: 10, on: makeDate(month: 5, day: 1), game: .Red, ball: "poke")
        logCatch(squirtle, encounters: 10, on: makeDate(year: 2025, month: 5, day: 1), game: .Red, ball: "poke")
        logCatch(squirtle, encounters: 10, on: makeDate(year: 2025, month: 5, day: 2), game: .Red, ball: "poke")

        let review = getReview(year: 2026)

        XCTAssertEqual(review.bestMonthForShinies, YearInReview.MonthCount(month: 3, count: 2))
        XCTAssertEqual(review.favouriteGame?.key, .Scarlet)
        XCTAssertEqual(review.topBalls.map { $0.key }, ["ultra", "poke"])
        XCTAssertEqual(review.favouriteMethod?.key, .Encounters)
    }

    func test_topBalls_areTheThreeMostUsed_leavingOutCatchesThatGotAway() {
        for (index, ball) in ["ultra", "ultra", "ultra", "great", "great", "poke", "luxury", "dusk"].enumerated() {
            logCatch(bulbasaur, encounters: 10, on: makeDate(month: 1, day: index + 1), ball: ball)
        }
        logCatch(bulbasaur, encounters: 10, on: makeDate(month: 2, day: 1), ball: "luxury", isFailed: true)

        let review = getReview(year: 2026)

        XCTAssertEqual(review.topBalls.map { $0.key }, ["ultra", "great", "dusk"])
        XCTAssertEqual(review.topBalls.map { $0.count }, [3, 2, 1])
    }

    func test_emptyYear_hasNoHighlights() {
        let review = getReview()

        XCTAssertEqual(review.year, 2026)
        XCTAssertEqual(review.foundCount, 0)
        XCTAssertTrue(review.availableYears.isEmpty)
        XCTAssertNil(review.firstShiny)
        XCTAssertNil(review.luckiestHunt)
        XCTAssertNil(review.fullOddsLuck)
        XCTAssertNil(review.favouriteGame)
        XCTAssertTrue(review.topBalls.isEmpty)
    }
}
