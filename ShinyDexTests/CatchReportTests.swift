import XCTest
@testable import ShinyDex

final class CatchReportTests: XCTestCase {
    private let ralts = 0, zubat = 1
    private var catches: InMemoryCatchRepository!
    private var pokemon: InMemoryPokemonRepository!
    private var days: InMemoryDailyEncountersRepository!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        catches = InMemoryCatchRepository()
        pokemon = InMemoryPokemonRepository(names: ["Ralts", "Zubat"])
        days = InMemoryDailyEncountersRepository()
    }

    private func makeDate(month: Int, day: Int) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: month, day: day, hour: 12).date!
    }

    @discardableResult
    private func addCatch(of number: Int, encounters: Int, month: Int, day: Int, isFailed: Bool = false) -> Catch {
        let caught = Catch(number: number, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: encounters, isShinyCharmActive: false,
                           caughtDate: makeDate(month: month, day: day), isFailed: isFailed)
        catches.insert(caught)
        return caught
    }

    private func record(_ count: Int, of number: Int, month: Int, day: Int) {
        days.save(DailyEncounters(day: EncounterDay(year: 2026, month: month, day: day), count: count, countsByPokemon: [number: count]))
    }

    private func makeReport(for caught: Catch) -> CatchReport? {
        return GetCatchReportHandler(catchRepository: catches, pokemonRepository: pokemon, dailyEncountersRepository: days, calendar: calendar)
            .handle(GetCatchReportQuery(catchId: CatchID(rawValue: caught.id)))
    }

    func test_countsWhichShinyThisIsOverallAndForTheSpecies() {
        addCatch(of: ralts, encounters: 100, month: 1, day: 1)
        addCatch(of: zubat, encounters: 200, month: 2, day: 1)
        addCatch(of: zubat, encounters: 50, month: 2, day: 2, isFailed: true)
        let latest = addCatch(of: ralts, encounters: 300, month: 3, day: 1)

        let report = makeReport(for: latest)!

        XCTAssertEqual(report.shinyNumber, 3)
        XCTAssertEqual(report.speciesCatchNumber, 2)
    }

    func test_comparesEncountersWithTheOdds() {
        let caught = addCatch(of: ralts, encounters: 4096, month: 1, day: 1)

        let report = makeReport(for: caught)!

        XCTAssertEqual(report.odds, 4096)
        XCTAssertEqual(report.chanceOfFindingSooner, CatchOdds.calculateChanceOfFindingSooner(caught))
    }

    func test_ranksByFewestEncounters() {
        addCatch(of: zubat, encounters: 100, month: 1, day: 1)
        addCatch(of: zubat, encounters: 900, month: 1, day: 2)
        let caught = addCatch(of: ralts, encounters: 500, month: 1, day: 3)

        let report = makeReport(for: caught)!

        XCTAssertEqual(report.encounterRank, 2)
        XCTAssertEqual(report.rankedHuntCount, 3)
    }

    func test_huntLengthStartsAfterThePreviousCatchOfTheSpecies() {
        addCatch(of: ralts, encounters: 100, month: 1, day: 5)
        record(50, of: ralts, month: 1, day: 3)
        record(80, of: ralts, month: 1, day: 10)
        record(20, of: zubat, month: 1, day: 11)
        record(90, of: ralts, month: 1, day: 14)
        let caught = addCatch(of: ralts, encounters: 170, month: 1, day: 14)

        let report = makeReport(for: caught)!

        XCTAssertEqual(report.daysHunted, 5)
        XCTAssertEqual(report.activeDays, 2)
    }

    func test_noHuntLength_withoutTrackedDays() {
        XCTAssertNil(makeReport(for: addCatch(of: ralts, encounters: 10, month: 1, day: 1))?.daysHunted)
    }

    func test_listsThePhasesFoundOnTheWay() {
        let phase = addCatch(of: zubat, encounters: 30, month: 1, day: 1)
        let caught = addCatch(of: ralts, encounters: 90, month: 1, day: 2)
        caught.phaseCatchIds = [phase.id]
        catches.update(caught)

        XCTAssertEqual(makeReport(for: caught)?.phases.map { $0.pokemonName }, ["Zubat"])
    }

    func test_noReportForAShinyThatGotAway() {
        XCTAssertNil(makeReport(for: addCatch(of: ralts, encounters: 10, month: 1, day: 1, isFailed: true)))
    }

    func test_loggingACatchReturnsItsID() {
        let ledgers = InMemoryEncounterLedgerRepository()
        let handler = LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: ledgers)

        let id = handler.handle(LogCatchCommand(number: ralts, outcome: .caught(ball: "poke"), date: makeDate(month: 1, day: 1)))

        XCTAssertEqual(id?.rawValue, catches.getAll().first?.id)
    }
}
