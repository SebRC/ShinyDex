import XCTest
@testable import ShinyDex

final class EncounterHistoryTests: XCTestCase {
    private var days: InMemoryDailyEncountersRepository!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    override func setUp() {
        days = InMemoryDailyEncountersRepository()
    }

    private func makeDate(month: Int = 7, day: Int, hour: Int = 0) -> Date {
        return DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2026, month: month, day: day, hour: hour).date!
    }

    private func record(_ count: Int, month: Int = 7, day: Int) {
        days.save(DailyEncounters(day: EncounterDay(year: 2026, month: month, day: day), count: count))
    }

    private func getHistory(now: Date, recentDayCount: Int = 30) -> EncounterHistory {
        let handler = GetEncounterHistoryHandler(dailyEncountersRepository: days, calendar: calendar, makeCurrentDate: { now })
        return handler.handle(GetEncounterHistoryQuery(recentDayCount: recentDayCount))
    }

    func test_withNoDays_historyIsEmpty() {
        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertTrue(history.recordedDays.isEmpty)
        XCTAssertNil(history.busiestDay)
        XCTAssertNil(history.averagePerActiveDay)
        XCTAssertEqual(history.recentDays.count, 30)
        XCTAssertTrue(history.recentDays.allSatisfy { $0.count == 0 })
    }

    func test_recordedDays_areNewestFirst_andSkipEmptyDays() {
        record(40, day: 3)
        record(0, day: 5)
        record(120, day: 9)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.recordedDays, [
            EncounterHistory.Day(date: makeDate(day: 9), count: 120),
            EncounterHistory.Day(date: makeDate(day: 3), count: 40)
        ])
    }

    func test_recentDays_endToday_oldestFirst_withMissingDaysAsZero() {
        record(5, day: 8)
        record(7, day: 10)
        record(99, day: 1)

        let history = getHistory(now: makeDate(day: 10, hour: 23), recentDayCount: 4)

        XCTAssertEqual(history.recentDays, [
            EncounterHistory.Day(date: makeDate(day: 7), count: 0),
            EncounterHistory.Day(date: makeDate(day: 8), count: 5),
            EncounterHistory.Day(date: makeDate(day: 9), count: 0),
            EncounterHistory.Day(date: makeDate(day: 10), count: 7)
        ])
    }

    func test_recentDays_crossMonthBoundaries() {
        record(12, month: 6, day: 30)

        let history = getHistory(now: makeDate(day: 1, hour: 8), recentDayCount: 2)

        XCTAssertEqual(history.recentDays, [
            EncounterHistory.Day(date: makeDate(month: 6, day: 30), count: 12),
            EncounterHistory.Day(date: makeDate(day: 1), count: 0)
        ])
    }

    func test_busiestDay_isTheHighestCount_preferringTheMostRecentOnTies() {
        record(300, day: 2)
        record(300, day: 6)
        record(100, day: 8)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.busiestDay, EncounterHistory.Day(date: makeDate(day: 6), count: 300))
    }

    func test_average_onlyCountsDaysWithEncounters() {
        record(10, day: 2)
        record(0, day: 3)
        record(25, day: 4)

        let history = getHistory(now: makeDate(day: 10, hour: 12))

        XCTAssertEqual(history.averagePerActiveDay, 18)
    }
}
