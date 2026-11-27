import XCTest
@testable import ShinyDex

class CatchStatsTests: XCTestCase {
    fileprivate var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    fileprivate func makeDate(_ year: Int) -> Date {
        return calendar.date(from: DateComponents(year: year, month: 6, day: 1))!
    }

    fileprivate func makeCatch(number: Int = 0, ball: String = "poke", game: Games = .Red, method: HuntMethod = .Encounters, isShinyCharmActive: Bool = false, encounters: Int, year: Int?, isFailed: Bool = false) -> Catch {
        return Catch(number: number, caughtBall: ball, game: game, huntMethod: method, encounters: encounters, isShinyCharmActive: isShinyCharmActive, caughtDate: year.map { makeDate($0) }, isFailed: isFailed)
    }

    func test_missingIVsCount_leavesOutCatchesWithIVs_gotAwayOnes_andGenOneAndTwo() {
        let withIVs = Catch(number: 0, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil)
        withIVs.ivs = IndividualValues().setting(31, for: .hp)
        let catches = [
            withIVs,
            Catch(number: 1, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil),
            Catch(number: 2, caughtBall: "poke", game: .Gold, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil),
            Catch(number: 3, caughtBall: "none", game: .Scarlet, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil, isFailed: true)
        ]

        XCTAssertEqual(CatchStats(catches: catches, calendar: calendar).missingIVsCount, 1)
    }

    func test_failedShinies_countAsFound_butNotCaught() {
        let stats = CatchStats(catches: [
            makeCatch(number: 0, encounters: 100, year: 2023),
            makeCatch(number: 0, encounters: 200, year: 2023),
            makeCatch(number: 0, encounters: 300, year: 2023),
            makeCatch(number: 24, ball: CatchRules.noBall, encounters: 400, year: 2023, isFailed: true)
        ], calendar: calendar)

        XCTAssertEqual(stats.foundCount, 4)
        XCTAssertEqual(stats.caughtCount, 3)
        XCTAssertEqual(stats.failedCount, 1)
        XCTAssertEqual(stats.catchRatePercent, 75)
        XCTAssertEqual(stats.caughtSpeciesCount, 1, "A species that only got away hasn't been caught")
    }

    func test_failedShinies_countTowardsEncounters_averages_years_andRecords() {
        let failed = makeCatch(ball: CatchRules.noBall, encounters: 900, year: 2024, isFailed: true)
        let stats = CatchStats(catches: [makeCatch(encounters: 100, year: 2024), failed], calendar: calendar)

        XCTAssertEqual(stats.totalEncounters, 1000)
        XCTAssertEqual(stats.averageEncounters, 500)
        XCTAssertEqual(stats.years, [CatchStats.YearStat(year: 2024, foundCount: 2, averageEncounters: 500)])
        XCTAssertTrue(stats.longestHunts.first === failed)
    }

    func test_failedShinies_areLeftOutOfBallGameAndMethodBreakdowns() {
        let stats = CatchStats(catches: [
            makeCatch(ball: "ultra", game: .X, method: .Masuda, encounters: 1, year: 2023),
            makeCatch(ball: CatchRules.noBall, game: .Red, method: .ChainFishing, encounters: 1, year: 2023, isFailed: true)
        ], calendar: calendar)

        XCTAssertEqual(stats.ballUsage.map { $0.key }, ["ultra"])
        XCTAssertEqual(stats.gameUsage.map { $0.key }, [.X])
        XCTAssertEqual(stats.methodUsage.map { $0.key }, [.Masuda])
    }

    func test_catchRate_isNilWithoutShinies() {
        XCTAssertNil(CatchStats(catches: [], calendar: calendar).catchRatePercent)
    }

    func test_totals_countEveryCatch() {
        let stats = CatchStats(catches: [
            makeCatch(number: 0, encounters: 100, year: 2023),
            makeCatch(number: 0, encounters: 300, year: 2024),
            makeCatch(number: 24, encounters: 0, year: nil)
        ], calendar: calendar)

        XCTAssertEqual(stats.foundCount, 3)
        XCTAssertEqual(stats.caughtSpeciesCount, 2)
        XCTAssertEqual(stats.totalEncounters, 400)
    }

    func test_average_ignoresCatchesWithoutEncounters() {
        let stats = CatchStats(catches: [
            makeCatch(encounters: 100, year: 2023),
            makeCatch(encounters: 301, year: 2023),
            makeCatch(encounters: 0, year: nil)
        ], calendar: calendar)

        XCTAssertEqual(stats.catchesWithEncounters, 2)
        XCTAssertEqual(stats.averageEncounters, 201)
    }

    func test_average_isNilWithoutEncounters() {
        let stats = CatchStats(catches: [makeCatch(encounters: 0, year: 2023)], calendar: calendar)

        XCTAssertNil(stats.averageEncounters)
        XCTAssertTrue(stats.shortestHunts.isEmpty)
        XCTAssertTrue(stats.longestHunts.isEmpty)
    }

    func test_years_areOldestFirst_withPerYearAverages_andUndatedCountedSeparately() {
        let stats = CatchStats(catches: [
            makeCatch(encounters: 400, year: 2024),
            makeCatch(encounters: 100, year: 2022),
            makeCatch(encounters: 300, year: 2022),
            makeCatch(encounters: 0, year: 2024),
            makeCatch(encounters: 50, year: nil)
        ], calendar: calendar)

        XCTAssertEqual(stats.years, [
            CatchStats.YearStat(year: 2022, foundCount: 2, averageEncounters: 200),
            CatchStats.YearStat(year: 2024, foundCount: 2, averageEncounters: 400)
        ])
        XCTAssertEqual(stats.undatedCount, 1)
    }

    func test_ballUsage_mostUsedFirst_tiesAlphabetical_andSkipsNone() {
        let stats = CatchStats(catches: [
            makeCatch(ball: "ultra", encounters: 1, year: 2023),
            makeCatch(ball: "great", encounters: 1, year: 2023),
            makeCatch(ball: "ultra", encounters: 1, year: 2023),
            makeCatch(ball: "dive", encounters: 1, year: 2023),
            makeCatch(ball: CatchRules.noBall, encounters: 1, year: 2023)
        ], calendar: calendar)

        XCTAssertEqual(stats.ballUsage.map { $0.key }, ["ultra", "dive", "great"])
        XCTAssertEqual(stats.ballUsage.map { $0.count }, [2, 1, 1])
    }

    func test_gameAndMethodUsage_mostUsedFirst() {
        let stats = CatchStats(catches: [
            makeCatch(game: .X, method: .ChainFishing, encounters: 1, year: 2023),
            makeCatch(game: .X, method: .Masuda, encounters: 1, year: 2023),
            makeCatch(game: .Red, method: .Masuda, encounters: 1, year: 2023)
        ], calendar: calendar)

        XCTAssertEqual(stats.gameUsage.map { $0.key }, [.X, .Red])
        XCTAssertEqual(stats.methodUsage.map { $0.key }, [.Masuda, .ChainFishing])
    }

    func test_natureUsage_mostCommonFirst_tiesAlphabetical_andCountsCatchesWithoutNatureAsUnknown() {
        let natures: [Nature?] = [.timid, .adamant, .timid, .bold, nil]
        let catches = natures.map { nature -> Catch in
            let caught = makeCatch(encounters: 1, year: 2023)
            caught.nature = nature
            return caught
        }
        let failed = makeCatch(ball: CatchRules.noBall, encounters: 1, year: 2023, isFailed: true)
        failed.nature = .jolly

        let stats = CatchStats(catches: catches + [failed], calendar: calendar)

        XCTAssertEqual(stats.natureUsage.map { $0.key }, [.timid, .adamant, .bold])
        XCTAssertEqual(stats.natureUsage.map { $0.count }, [2, 1, 1])
        XCTAssertEqual(stats.unknownNatureCount, 1)
    }

    func test_genderUsage_countsFixedGenders_andCatchesWithoutGenderAsUnknown() {
        let genders: [Gender?] = [.female, .female, .male, nil]
        let catches = genders.map { gender -> Catch in
            let caught = makeCatch(number: 1, encounters: 1, year: 2023)
            caught.gender = gender
            return caught
        }
        let genderlessSpecies = makeCatch(number: 80, encounters: 1, year: 2023)
        let failed = makeCatch(ball: CatchRules.noBall, encounters: 1, year: 2023, isFailed: true)
        failed.gender = .male

        let stats = CatchStats(catches: catches + [genderlessSpecies, failed], calendar: calendar,
                               genders: PokemonGenders(fixedGendersByNumber: [80: .genderless]))

        XCTAssertEqual(stats.genderUsage.map { $0.key }, [.female, .genderless, .male])
        XCTAssertEqual(stats.genderUsage.map { $0.count }, [2, 1, 1])
        XCTAssertEqual(stats.unknownGenderCount, 1)
    }

    func test_huntRankings_orderByEncounters_andLeaveOutHuntsWithoutEncounters() {
        let fastest = makeCatch(number: 1, encounters: 12, year: 2023)
        let middle = makeCatch(number: 3, encounters: 500, year: 2023)
        let longest = makeCatch(number: 2, encounters: 9000, year: 2023)
        let stats = CatchStats(catches: [makeCatch(encounters: 0, year: 2023), longest, fastest, middle], calendar: calendar)

        XCTAssertEqual(stats.shortestHunts.map { $0.encounters }, [12, 500, 9000])
        XCTAssertEqual(stats.longestHunts.map { $0.encounters }, [9000, 500, 12])
        XCTAssertTrue(stats.shortestHunts.first === fastest)
        XCTAssertTrue(stats.longestHunts.first === longest)
    }

    func test_huntRankings_keepOnlyTheTopTen() {
        let catches = (1...15).map { makeCatch(encounters: $0 * 100, year: 2023) }
        let stats = CatchStats(catches: catches, calendar: calendar)

        XCTAssertEqual(stats.shortestHunts.map { $0.encounters }, (1...10).map { $0 * 100 })
        XCTAssertEqual(stats.longestHunts.map { $0.encounters }, (6...15).reversed().map { $0 * 100 })
    }

    fileprivate func makeCatch(on date: Date?, isFailed: Bool = false) -> Catch {
        return Catch(number: 0, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed)
    }

    fileprivate func makeDate(year: Int, month: Int, day: Int) -> Date {
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func test_months_countEveryMonth_includingFailedShinies_andSkipUndated() {
        let stats = CatchStats(catches: [
            makeCatch(on: makeDate(year: 2022, month: 3, day: 1)),
            makeCatch(on: makeDate(year: 2024, month: 3, day: 20), isFailed: true),
            makeCatch(on: makeDate(year: 2024, month: 12, day: 31)),
            makeCatch(on: nil)
        ], calendar: calendar)

        XCTAssertEqual(stats.months.map { $0.period }, Array(1...12))
        XCTAssertEqual(stats.months.map { $0.foundCount }, [0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1])
    }

    func test_weekdays_countEveryWeekday_usingCalendarWeekdayNumbers() {
        let sunday = makeDate(year: 2024, month: 6, day: 2)
        let wednesday = makeDate(year: 2024, month: 6, day: 5)
        let stats = CatchStats(catches: [makeCatch(on: sunday), makeCatch(on: wednesday), makeCatch(on: wednesday)], calendar: calendar)

        XCTAssertEqual(stats.weekdays.map { $0.period }, Array(1...7))
        XCTAssertEqual(stats.weekdays.map { $0.foundCount }, [1, 0, 0, 2, 0, 0, 0])
    }

    func test_luckiestDates_ignoreYear_needMoreThanOneShiny_andAreMostFoundFirstThenChronological() {
        let stats = CatchStats(catches: [
            makeCatch(on: makeDate(year: 2021, month: 10, day: 31)),
            makeCatch(on: makeDate(year: 2023, month: 10, day: 31)),
            makeCatch(on: makeDate(year: 2024, month: 2, day: 14)),
            makeCatch(on: makeDate(year: 2024, month: 2, day: 14)),
            makeCatch(on: makeDate(year: 2025, month: 2, day: 14)),
            makeCatch(on: makeDate(year: 2022, month: 1, day: 5)),
            makeCatch(on: makeDate(year: 2023, month: 1, day: 5)),
            makeCatch(on: makeDate(year: 2024, month: 7, day: 4))
        ], calendar: calendar)

        XCTAssertEqual(stats.luckiestDates, [
            CatchStats.DateStat(month: 2, day: 14, foundCount: 3),
            CatchStats.DateStat(month: 1, day: 5, foundCount: 2),
            CatchStats.DateStat(month: 10, day: 31, foundCount: 2)
        ])
    }

    func test_fullOddsLuck_sumsEncountersOverFullOdds_perYearAndLifetime_includingFailedAndUndatedInLifetime() {
        let stats = CatchStats(catches: [
            makeCatch(game: .Red, encounters: 8192, year: 2023),
            makeCatch(game: .Black, encounters: 4096, year: 2023, isFailed: true),
            makeCatch(game: .Emerald, encounters: 2048, year: 2024),
            makeCatch(game: .Gold, encounters: 6144, year: nil)
        ], calendar: calendar)

        XCTAssertEqual(stats.yearLuck, [
            CatchStats.YearLuck(year: 2023, luck: CatchStats.Luck(expectedShinies: 1.5, foundCount: 2)),
            CatchStats.YearLuck(year: 2024, luck: CatchStats.Luck(expectedShinies: 0.25, foundCount: 1))
        ])
        XCTAssertEqual(stats.lifetimeLuck, CatchStats.Luck(expectedShinies: 2.5, foundCount: 4))
    }

    func test_fullOddsLuck_leavesOutMethodHunts_betterOdds_andCatchesWithoutEncounters() {
        let stats = CatchStats(catches: [
            makeCatch(game: .Red, encounters: 8192, year: 2023),
            makeCatch(game: .X, encounters: 4096, year: 2023),
            makeCatch(game: .Black, isShinyCharmActive: true, encounters: 2731, year: 2023),
            makeCatch(game: .Diamond, method: .Masuda, encounters: 1638, year: 2023),
            makeCatch(game: .Gold, method: .Gen2Breeding, encounters: 64, year: 2023),
            makeCatch(game: .X, method: .ChainFishing, encounters: 40, year: 2024),
            makeCatch(game: .LetsGoEevee, encounters: 500, year: 2024),
            makeCatch(game: .Red, encounters: 0, year: 2024)
        ], calendar: calendar)

        XCTAssertEqual(stats.yearLuck, [CatchStats.YearLuck(year: 2023, luck: CatchStats.Luck(expectedShinies: 1, foundCount: 1))])
        XCTAssertEqual(stats.lifetimeLuck, CatchStats.Luck(expectedShinies: 1, foundCount: 1))
    }

    func test_fullOddsLuck_isNilWithoutFullOddsHunts() {
        let stats = CatchStats(catches: [makeCatch(game: .X, encounters: 4096, year: 2023)], calendar: calendar)

        XCTAssertNil(stats.lifetimeLuck)
        XCTAssertEqual(stats.yearLuck, [])
    }
}
