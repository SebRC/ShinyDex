import XCTest
@testable import ShinyDex

final class EncounterHistoryTests: XCTestCase {
    private var days: InMemoryDailyEncountersRepository!
    private var catches: InMemoryCatchRepository!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        days = InMemoryDailyEncountersRepository()
        catches = InMemoryCatchRepository()
    }

    private func makeDate(year: Int = 2026, month: Int = 7, day: Int = 1, hour: Int = 0) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }

    private func record(_ count: Int, year: Int = 2026, month: Int = 7, day: Int) {
        days.save(DailyEncounters(day: EncounterDay(year: year, month: month, day: day), count: count))
    }

    private func logCatch(on date: Date, isFailed: Bool = false) {
        catches.insert(Catch(number: 1, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 100, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed))
    }

    private func getHistory(_ period: EncounterPeriod = .day, now: Date) -> EncounterHistory {
        let handler = GetEncounterHistoryHandler(dailyEncountersRepository: days, catchRepository: catches, calendar: calendar, makeCurrentDate: { now })
        return handler.handle(GetEncounterHistoryQuery(period: period))
    }

    private func entry(_ start: Date, _ count: Int) -> EncounterHistory.Entry {
        return EncounterHistory.Entry(start: start, count: count)
    }

    private func calendarDay(_ start: Date, _ count: Int, caught: Int = 0, gotAway: Int = 0) -> EncounterHistory.CalendarDay {
        return EncounterHistory.CalendarDay(start: start, count: count, caughtCount: caught, gotAwayCount: gotAway)
    }

    // MARK: Days

    func test_withNoDays_historyIsEmpty() {
        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertTrue(history.recorded.isEmpty)
        XCTAssertNil(history.busiest)
        XCTAssertNil(history.averagePerActivePeriod)
        XCTAssertNil(history.trackedSince)
        XCTAssertEqual(history.recent.count, 30)
        XCTAssertTrue(history.recent.allSatisfy { $0.count == 0 })
    }

    func test_recordedDays_areNewestFirst_andSkipEmptyDays() {
        record(40, day: 3)
        record(0, day: 5)
        record(120, day: 9)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.recorded, [entry(makeDate(day: 9), 120), entry(makeDate(day: 3), 40)])
    }

    func test_recentDays_endToday_oldestFirst_withMissingDaysAsZero() {
        record(5, day: 8)
        record(7, day: 10)

        let history = getHistory(now: makeDate(day: 10, hour: 23))

        XCTAssertEqual(history.recent.count, 30)
        XCTAssertEqual(Array(history.recent.suffix(4)), [
            entry(makeDate(day: 7), 0),
            entry(makeDate(day: 8), 5),
            entry(makeDate(day: 9), 0),
            entry(makeDate(day: 10), 7)
        ])
    }

    func test_recentDays_crossMonthBoundaries() {
        record(12, month: 6, day: 30)

        let history = getHistory(now: makeDate(day: 1, hour: 8))

        XCTAssertEqual(Array(history.recent.suffix(2)), [entry(makeDate(month: 6, day: 30), 12), entry(makeDate(day: 1), 0)])
    }

    func test_busiestDay_isTheHighestCount_preferringTheMostRecentOnTies() {
        record(300, day: 2)
        record(300, day: 6)
        record(100, day: 8)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.busiest, entry(makeDate(day: 6), 300))
    }

    func test_average_onlyCountsDaysWithEncounters() {
        record(10, day: 2)
        record(0, day: 3)
        record(25, day: 4)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.averagePerActivePeriod, 18)
    }

    func test_trackedSince_isTheEarliestTrackedDay() {
        record(0, month: 6, day: 20)
        record(15, day: 4)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.trackedSince, makeDate(month: 6, day: 20))
    }

    // MARK: Calendar and streaks

    func test_dayStreaks_comeFromTheTrackedDays() {
        record(10, day: 6)
        record(10, day: 8)
        record(10, day: 9)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.dayStreaks, EncounterHistory.DayStreaks(current: 2, longest: 2))
    }

    func test_calendar_isWholeWeeks_endingThisWeek_withFutureDaysEmpty() {
        var mondayCalendar = calendar
        mondayCalendar.firstWeekday = 2
        record(42, day: 8)
        let handler = GetEncounterHistoryHandler(dailyEncountersRepository: days, catchRepository: catches, calendar: mondayCalendar, makeCurrentDate: { self.makeDate(day: 8, hour: 12) })

        let weeks = handler.handle(GetEncounterHistoryQuery()).calendarWeeks

        XCTAssertEqual(weeks.count, GetEncounterHistoryHandler.calendarWeekCount)
        XCTAssertTrue(weeks.allSatisfy { $0.count == 7 })
        let thisWeek = weeks.last!
        XCTAssertEqual(thisWeek[0], calendarDay(makeDate(day: 6), 0))
        XCTAssertEqual(thisWeek[2], calendarDay(makeDate(day: 8), 42))
        XCTAssertNil(thisWeek[3])
        XCTAssertNil(thisWeek[6])
        XCTAssertEqual(weeks.first?.first, calendarDay(makeDate(month: 1, day: 12), 0))
    }

    func test_calendar_countsTheShiniesCaughtAndThoseThatGotAway_eachDay() {
        record(42, day: 8)
        logCatch(on: makeDate(day: 8, hour: 9))
        logCatch(on: makeDate(day: 8, hour: 21))
        logCatch(on: makeDate(day: 8, hour: 22), isFailed: true)
        logCatch(on: makeDate(day: 7, hour: 10))
        logCatch(on: makeDate(day: 6, hour: 10), isFailed: true)

        let days = getHistory(now: makeDate(day: 8, hour: 23)).calendarWeeks.joined().compactMap { $0 }

        XCTAssertEqual(days.first { $0.start == makeDate(day: 8) }, calendarDay(makeDate(day: 8), 42, caught: 2, gotAway: 1))
        XCTAssertEqual(days.first { $0.start == makeDate(day: 7) }, calendarDay(makeDate(day: 7), 0, caught: 1))
        XCTAssertEqual(days.first { $0.start == makeDate(day: 6) }, calendarDay(makeDate(day: 6), 0, gotAway: 1))
        XCTAssertEqual(days.first { $0.start == makeDate(day: 5) }, calendarDay(makeDate(day: 5), 0))
    }

    // MARK: Months

    func test_months_sumTheirDays() {
        record(100, month: 5, day: 31)
        record(40, month: 6, day: 1)
        record(60, month: 6, day: 30)
        record(25, day: 10)

        let history = getHistory(.month, now: makeDate(day: 15, hour: 12))

        XCTAssertEqual(history.recorded, [
            entry(makeDate(month: 7), 25),
            entry(makeDate(month: 6), 100),
            entry(makeDate(month: 5), 100)
        ])
    }

    func test_recentMonths_areTheLastTwelve_endingThisMonth() {
        record(80, year: 2025, month: 8, day: 3)
        record(70, year: 2025, month: 7, day: 3)

        let history = getHistory(.month, now: makeDate(day: 15, hour: 12))

        XCTAssertEqual(history.recent.count, 12)
        XCTAssertEqual(history.recent.first, entry(makeDate(year: 2025, month: 8), 80))
        XCTAssertEqual(history.recent.last, entry(makeDate(month: 7), 0))
    }

    func test_busiestMonth_andAveragePerActiveMonth() {
        record(100, month: 5, day: 2)
        record(300, month: 6, day: 2)
        record(0, day: 2)

        let history = getHistory(.month, now: makeDate(day: 15, hour: 12))

        XCTAssertEqual(history.busiest, entry(makeDate(month: 6), 300))
        XCTAssertEqual(history.averagePerActivePeriod, 200)
    }

    // MARK: Years

    func test_years_sumTheirDays_andRunFromTheFirstTrackedYearToNow() {
        record(500, year: 2024, month: 12, day: 31)
        record(200, year: 2026, month: 1, day: 1)
        record(300, year: 2026, month: 6, day: 5)

        let history = getHistory(.year, now: makeDate(day: 15, hour: 12))

        XCTAssertEqual(history.recent, [
            entry(makeDate(year: 2024, month: 1), 500),
            entry(makeDate(year: 2025, month: 1), 0),
            entry(makeDate(year: 2026, month: 1), 500)
        ])
        XCTAssertEqual(history.recorded, [entry(makeDate(year: 2026, month: 1), 500), entry(makeDate(year: 2024, month: 1), 500)])
        XCTAssertEqual(history.busiest, entry(makeDate(year: 2026, month: 1), 500))
    }

    func test_years_withNoDays_showOnlyThisYear() {
        let history = getHistory(.year, now: makeDate(day: 15, hour: 12))

        XCTAssertEqual(history.recent, [entry(makeDate(year: 2026, month: 1), 0)])
    }
}
