import XCTest
@testable import ShinyDex

final class YearComparisonTests: XCTestCase {
    private var catches: InMemoryCatchRepository!
    private var days: InMemoryDailyEncountersRepository!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        catches = InMemoryCatchRepository()
        days = InMemoryDailyEncountersRepository()
    }

    private func makeDate(year: Int = 2026, month: Int, day: Int) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: 12).date!
    }

    private func logCatch(year: Int = 2026, month: Int, day: Int, isFailed: Bool = false) {
        catches.insert(Catch(number: 0, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 10, isShinyCharmActive: false,
                             caughtDate: makeDate(year: year, month: month, day: day), isFailed: isFailed))
    }

    private func record(_ count: Int, year: Int = 2026, month: Int, day: Int) {
        days.save(DailyEncounters(day: EncounterDay(year: year, month: month, day: day), count: count))
    }

    private func compare(year: Int? = nil, now: Date? = nil) -> YearOnYear {
        let handler = GetYearComparisonHandler(catchRepository: catches, dailyEncountersRepository: days, calendar: calendar,
                                               makeCurrentDate: { now ?? self.makeDate(month: 6, day: 15) })
        return handler.handle(GetYearComparisonQuery(year: year))
    }

    // MARK: Months

    func test_countsShiniesAndEncountersPerMonthForBothYears() {
        logCatch(month: 2, day: 3)
        logCatch(month: 2, day: 20, isFailed: true)
        logCatch(year: 2025, month: 2, day: 1)
        logCatch(year: 2024, month: 2, day: 1)
        record(300, month: 2, day: 3)
        record(100, year: 2025, month: 2, day: 5)
        record(50, year: 2025, month: 2, day: 6)

        let february = compare().months[1]

        XCTAssertEqual(february.month, 2)
        XCTAssertEqual(february.shinies, 2)
        XCTAssertEqual(february.previousShinies, 1)
        XCTAssertEqual(february.encounters, 300)
        XCTAssertEqual(february.previousEncounters, 150)
    }

    func test_marksMonthsAfterTodayAsUpcoming() {
        let months = compare().months

        XCTAssertEqual(months.count, 12)
        XCTAssertFalse(months[5].isUpcoming)
        XCTAssertTrue(months[6].isUpcoming)
    }

    // MARK: Pace

    func test_comparesWithLastYearUpToTheSameDay() {
        logCatch(month: 1, day: 10)
        logCatch(month: 6, day: 15)
        logCatch(year: 2025, month: 6, day: 15)
        logCatch(year: 2025, month: 6, day: 16)
        logCatch(year: 2025, month: 9, day: 1)
        record(200, month: 3, day: 1)
        record(500, year: 2025, month: 3, day: 1)
        record(900, year: 2025, month: 7, day: 1)

        let comparison = compare()

        XCTAssertEqual(comparison.shinies, YearOnYear.Pace(current: 2, previous: 1, difference: 1))
        XCTAssertEqual(comparison.encounters, YearOnYear.Pace(current: 200, previous: 500, difference: -300))
        XCTAssertEqual(comparison.comparedUntil, calendar.startOfDay(for: makeDate(month: 6, day: 15)))
        XCTAssertFalse(comparison.isFullYear)
    }

    func test_comparesWholeYears_forAPastYear() {
        logCatch(year: 2025, month: 12, day: 30)
        logCatch(year: 2024, month: 1, day: 1)
        logCatch(year: 2024, month: 12, day: 31)

        let comparison = compare(year: 2025)

        XCTAssertEqual(comparison.previousYear, 2024)
        XCTAssertEqual(comparison.shinies, YearOnYear.Pace(current: 1, previous: 2, difference: -1))
        XCTAssertTrue(comparison.isFullYear)
        XCTAssertFalse(comparison.months.contains { $0.isUpcoming })
    }

    // MARK: Years

    func test_listsYearsWithDataAndTheCurrentYear_newestFirst() {
        logCatch(year: 2023, month: 5, day: 1)
        record(10, year: 2024, month: 1, day: 1)

        XCTAssertEqual(compare().availableYears, [2026, 2024, 2023])
    }

    func test_reportsWhenEncounterTrackingStarted_afterTheStartOfLastYear() {
        record(10, year: 2025, month: 8, day: 2)

        XCTAssertEqual(compare().encountersTrackedSince, calendar.startOfDay(for: makeDate(year: 2025, month: 8, day: 2)))
    }

    func test_reportsNoTrackingStart_whenLastYearWasFullyTracked() {
        record(10, year: 2024, month: 8, day: 2)

        XCTAssertNil(compare().encountersTrackedSince)
    }

    // MARK: Collection period

    func test_monthOfYearPeriodMatchesOnlyThatYearsMonth() {
        let period = CatchPeriod.monthOfYear(month: 3, year: 2025)

        XCTAssertTrue(period.contains(makeDate(year: 2025, month: 3, day: 9), calendar: calendar))
        XCTAssertFalse(period.contains(makeDate(year: 2026, month: 3, day: 9), calendar: calendar))
        XCTAssertFalse(period.contains(makeDate(year: 2025, month: 4, day: 9), calendar: calendar))
    }
}
