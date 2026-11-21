import XCTest
@testable import ShinyDex

final class ProgressHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var hunts: InMemoryHuntRepository!
    private var ledgers: InMemoryEncounterLedgerRepository!
    private var goals: InMemoryYearlyGoalRepository!
    private let bulbasaur = 0, charmander = 1, squirtle = 2
    private let now = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "UTC"), year: 2026, month: 7, day: 2, hour: 12).date!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Charmander", "Squirtle"])
        catches = InMemoryCatchRepository()
        hunts = InMemoryHuntRepository()
        ledgers = InMemoryEncounterLedgerRepository()
        goals = InMemoryYearlyGoalRepository()
    }

    private var changeEncountersHandler: ChangeEncountersHandler {
        return ChangeEncountersHandler(pokemonRepository: pokemon, catchRepository: catches, ledgerRepository: ledgers, odds: OddsService(), makeCurrentDate: { self.now })
    }

    private func changeEncounters(_ change: ChangeEncountersCommand.Change, of number: Int, times: Int = 1) {
        for _ in 0..<times {
            changeEncountersHandler.handle(ChangeEncountersCommand(number: number, change: change))
        }
    }

    private func log(_ number: Int, outcome: LogCatchCommand.Outcome = .caught(ball: "poke")) {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: ledgers, makeCurrentDate: { self.now })
            .handle(LogCatchCommand(number: number, outcome: outcome, date: now))
    }

    private func getStatistics() -> CatchStatistics {
        return GetCatchStatisticsHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: ledgers, yearlyGoalRepository: goals,
                                         calendar: calendar, makeCurrentDate: { self.now })
            .handle(GetCatchStatisticsQuery())
    }

    private func setGoal(_ target: Int?, year: Int = 2026) {
        SetYearlyGoalHandler(yearlyGoalRepository: goals).handle(SetYearlyGoalCommand(year: year, target: target))
    }

    // MARK: Counting encounters

    func test_streaksAreUntracked_untilTheFirstEncounterIsCounted() {
        XCTAssertNil(getStatistics().streaks)

        changeEncounters(.increment, of: bulbasaur)

        XCTAssertEqual(getStatistics().streaks, CatchStatistics.Streaks(current: 1, longest: 1, trackedSince: now))
    }

    func test_encountersAcrossEveryHunt_addUpToOneStreak() {
        SetIncrementHandler(pokemonRepository: pokemon).handle(SetIncrementCommand(number: charmander, increment: 3))

        changeEncounters(.increment, of: bulbasaur, times: 4)
        changeEncounters(.increment, of: charmander, times: 2)

        XCTAssertEqual(getStatistics().streaks?.current, 10)
    }

    func test_incrementingAWholeHunt_countsEveryMember() {
        let hunt = Hunt(name: "Starters", indexes: [bulbasaur, squirtle], priority: 0, isCollapsed: false)
        hunts.save(hunt)

        IncrementAllInHuntHandler(huntRepository: hunts, changeEncounters: changeEncountersHandler).handle(IncrementAllInHuntCommand(huntId: HuntID(rawValue: hunt.id)))

        XCTAssertEqual(getStatistics().streaks?.current, 2)
    }

    func test_typingAHigherCount_countsTheDifference_butTypingALowerOneTakesNothingAway() {
        changeEncounters(.set(50), of: bulbasaur)
        changeEncounters(.set(80), of: bulbasaur)
        changeEncounters(.set(0), of: bulbasaur)

        XCTAssertEqual(getStatistics().streaks?.current, 80)
    }

    func test_decrementing_takesAnEncounterBackOff() {
        changeEncounters(.increment, of: bulbasaur, times: 5)
        changeEncounters(.decrement, of: bulbasaur, times: 2)

        XCTAssertEqual(getStatistics().streaks?.current, 3)
    }

    func test_decrementing_neverReachesBackPastTheLatestShiny() {
        changeEncounters(.increment, of: bulbasaur, times: 5)
        log(bulbasaur)
        changeEncounters(.increment, of: charmander)

        changeEncounters(.decrement, of: bulbasaur, times: 3)

        XCTAssertEqual(getStatistics().streaks?.current, 0)
        XCTAssertEqual(getStatistics().streaks?.longest, 5)
    }

    // MARK: Logging shinies

    func test_loggingAShiny_endsTheStreak_andStartsANewOne() {
        changeEncounters(.increment, of: bulbasaur, times: 7)
        log(bulbasaur)
        changeEncounters(.increment, of: bulbasaur, times: 2)

        XCTAssertEqual(catches.getAll().first?.encounterTotalAtFind, 7)
        XCTAssertEqual(getStatistics().streaks?.current, 2)
        XCTAssertEqual(getStatistics().streaks?.longest, 7)
    }

    func test_aShinyThatGotAway_endsTheStreakToo() {
        changeEncounters(.increment, of: squirtle, times: 4)
        log(squirtle, outcome: .gotAway)

        XCTAssertEqual(getStatistics().streaks?.current, 0)
    }

    func test_aShinyLoggedBeforeAnyEncounter_startsTracking() {
        log(bulbasaur)

        XCTAssertEqual(catches.getAll().first?.encounterTotalAtFind, 0)
        XCTAssertEqual(getStatistics().streaks?.trackedSince, now)
    }

    func test_aFailedSave_leavesTheLedgerUntouched() {
        catches.failsToSave = true

        log(bulbasaur)

        XCTAssertNil(ledgers.stored)
    }

    func test_deletingTheLatestShiny_bringsTheStreakBeforeItBack() {
        changeEncounters(.increment, of: bulbasaur, times: 3)
        log(bulbasaur)
        changeEncounters(.increment, of: bulbasaur, times: 6)
        log(bulbasaur)
        changeEncounters(.increment, of: bulbasaur)
        let latest = catches.getAll().max { ($0.encounterTotalAtFind ?? 0) < ($1.encounterTotalAtFind ?? 0) }!

        DeleteCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(DeleteCatchCommand(catchId: CatchID(rawValue: latest.id)))

        XCTAssertEqual(getStatistics().streaks?.current, 7)
    }

    // MARK: Yearly goal

    func test_withoutAGoal_theStatsHaveNone() {
        XCTAssertNil(getStatistics().goal)
        XCTAssertEqual(getStatistics().currentYear, 2026)
    }

    func test_settingAGoal_showsThisYearsProgress() {
        log(bulbasaur)
        log(charmander, outcome: .gotAway)

        setGoal(20)

        XCTAssertEqual(getStatistics().goal, CatchStatistics.Goal(target: 20, foundCount: 2, expectedByNow: 10, isReached: false, aheadOfPace: -8))
    }

    func test_changingAGoal_replacesIt() {
        setGoal(20)
        setGoal(5)

        XCTAssertEqual(goals.getAll(), [YearlyGoal(year: 2026, target: 5)])
    }

    func test_clearingAGoal_removesIt() {
        setGoal(20)
        setGoal(nil)
        XCTAssertEqual(goals.getAll(), [])

        setGoal(20)
        setGoal(0)
        XCTAssertEqual(goals.getAll(), [])
    }

    func test_goalsForOtherYears_areKept_butNotShown() {
        setGoal(12, year: 2025)

        XCTAssertNil(getStatistics().goal)
        XCTAssertEqual(goals.getAll(), [YearlyGoal(year: 2025, target: 12)])
    }
}
