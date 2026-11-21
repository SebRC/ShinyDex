import XCTest
@testable import ShinyDex

final class HuntingDayStreaksTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func makeDays(_ counts: [(month: Int, day: Int, count: Int)]) -> [DailyEncounters] {
        return counts.map { DailyEncounters(day: EncounterDay(year: 2026, month: $0.month, day: $0.day), count: $0.count) }
    }

    private func makeStreaks(_ counts: [(month: Int, day: Int, count: Int)], todayMonth: Int = 7, todayDay: Int) -> HuntingDayStreaks {
        return HuntingDayStreaks(days: makeDays(counts), today: EncounterDay(year: 2026, month: todayMonth, day: todayDay), calendar: calendar)
    }

    func test_withNoDays_bothStreaksAreZero() {
        let streaks = makeStreaks([], todayDay: 10)

        XCTAssertEqual(streaks, makeStreaks([(7, 1, 0)], todayDay: 10))
        XCTAssertEqual(streaks.current, 0)
        XCTAssertEqual(streaks.longest, 0)
    }

    func test_currentStreak_countsDaysInARowEndingToday() {
        let streaks = makeStreaks([(7, 7, 5), (7, 8, 5), (7, 9, 5), (7, 10, 5)], todayDay: 10)

        XCTAssertEqual(streaks.current, 4)
    }

    func test_todayWithoutEncounters_keepsYesterdaysStreakGoing() {
        let streaks = makeStreaks([(7, 8, 5), (7, 9, 5), (7, 10, 0)], todayDay: 10)

        XCTAssertEqual(streaks.current, 2)
    }

    func test_aMissedDay_endsTheCurrentStreak() {
        let streaks = makeStreaks([(7, 5, 5), (7, 6, 5), (7, 8, 5)], todayDay: 10)

        XCTAssertEqual(streaks.current, 0)
        XCTAssertEqual(streaks.longest, 2)
    }

    func test_daysWithZeroEncounters_breakStreaks() {
        let streaks = makeStreaks([(7, 7, 5), (7, 8, 0), (7, 9, 5), (7, 10, 5)], todayDay: 10)

        XCTAssertEqual(streaks.current, 2)
        XCTAssertEqual(streaks.longest, 2)
    }

    func test_longestStreak_findsTheLongestRun_acrossMonthEnds() {
        let streaks = makeStreaks([(6, 29, 1), (6, 30, 1), (7, 1, 1), (7, 2, 1), (7, 9, 1), (7, 10, 1)], todayDay: 10)

        XCTAssertEqual(streaks.current, 2)
        XCTAssertEqual(streaks.longest, 4)
    }

    func test_encounterDay_addsDaysAcrossYears() {
        XCTAssertEqual(EncounterDay(year: 2026, month: 12, day: 31).adding(days: 1, calendar: calendar), EncounterDay(year: 2027, month: 1, day: 1))
        XCTAssertEqual(EncounterDay(year: 2026, month: 3, day: 1).adding(days: -1, calendar: calendar), EncounterDay(year: 2026, month: 2, day: 28))
    }
}
