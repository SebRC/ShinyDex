import XCTest
@testable import ShinyDex

final class OnThisDayTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let bulbasaur = 0, charmander = 1, squirtle = 2
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Charmander", "Squirtle"])
        catches = InMemoryCatchRepository()
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }

    private func logCatch(_ number: Int, on date: Date?, isFailed: Bool = false) {
        catches.insert(Catch(number: number, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 100, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed))
    }

    private func getOnThisDay(now: Date) -> [OnThisDayCatch] {
        return GetOnThisDayHandler(catchRepository: catches, pokemonRepository: pokemon, calendar: calendar, makeCurrentDate: { now }).handle(GetOnThisDayQuery())
    }

    func test_findsShiniesFromTodaysDateInEarlierYears_newestYearFirst() {
        logCatch(bulbasaur, on: makeDate(year: 2023, month: 11, day: 21))
        logCatch(charmander, on: makeDate(year: 2025, month: 11, day: 21, hour: 8))
        logCatch(squirtle, on: makeDate(year: 2025, month: 11, day: 20))

        let found = getOnThisDay(now: makeDate(year: 2026, month: 11, day: 21))

        XCTAssertEqual(found.map { $0.caught.pokemonName }, ["Charmander", "Bulbasaur"])
        XCTAssertEqual(found.map { $0.yearsAgo }, [1, 3])
    }

    func test_shiniesFromThisYear_andUndatedOnes_areLeftOut() {
        logCatch(bulbasaur, on: makeDate(year: 2026, month: 11, day: 21, hour: 6))
        logCatch(charmander, on: nil)

        XCTAssertTrue(getOnThisDay(now: makeDate(year: 2026, month: 11, day: 21)).isEmpty)
    }

    func test_onesThatGotAway_areIncluded() {
        logCatch(bulbasaur, on: makeDate(year: 2025, month: 11, day: 21), isFailed: true)

        XCTAssertEqual(getOnThisDay(now: makeDate(year: 2026, month: 11, day: 21)).first?.caught.isFailed, true)
    }

    func test_leapDayShinies_showOnTheLastDayOfFebruary_inOtherYears() {
        logCatch(bulbasaur, on: makeDate(year: 2024, month: 2, day: 29))
        logCatch(charmander, on: makeDate(year: 2025, month: 2, day: 28))

        XCTAssertEqual(getOnThisDay(now: makeDate(year: 2026, month: 2, day: 28)).map { $0.caught.pokemonName }, ["Charmander", "Bulbasaur"])
        XCTAssertEqual(getOnThisDay(now: makeDate(year: 2028, month: 2, day: 28)).map { $0.caught.pokemonName }, ["Charmander"])
        XCTAssertEqual(getOnThisDay(now: makeDate(year: 2028, month: 2, day: 29)).map { $0.caught.pokemonName }, ["Bulbasaur"])
    }
}
