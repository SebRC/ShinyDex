import XCTest
@testable import ShinyDex

final class DryStreaksTests: XCTestCase {
    private let trackedSince = Date(timeIntervalSince1970: 1_700_000_000)
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func makeLedger(total: Int) -> EncounterLedger {
        return EncounterLedger(total: total, trackedSince: trackedSince)
    }

    private func makeCatch(atLedgerTotal total: Int?, on date: Date? = nil, isFailed: Bool = false) -> Catch {
        let caught = Catch(number: 0, caughtBall: "poke", game: .Red, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed)
        caught.encounterTotalAtFind = total
        return caught
    }

    // MARK: Ledger

    func test_ledger_countsOnlyPositiveEncounters() {
        let ledger = makeLedger(total: 10)

        ledger.count(5)
        ledger.count(-20)

        XCTAssertEqual(ledger.total, 15)
    }

    func test_ledger_uncountsDownToTheFloor_butNoFurther() {
        let ledger = makeLedger(total: 105)

        ledger.uncount(3, keepingAtLeast: 100)
        XCTAssertEqual(ledger.total, 102)

        ledger.uncount(10, keepingAtLeast: 100)
        XCTAssertEqual(ledger.total, 100)
    }

    func test_ledger_neverRaisesTheTotalWhenUncounting() {
        let ledger = makeLedger(total: 50)

        ledger.uncount(1, keepingAtLeast: 80)

        XCTAssertEqual(ledger.total, 50)
    }

    // MARK: Streaks

    func test_withoutTrackedShinies_bothStreaksAreEverythingCounted() {
        let streaks = DryStreaks(ledger: makeLedger(total: 450), catches: [makeCatch(atLedgerTotal: nil)])

        XCTAssertEqual(streaks.current, 450)
        XCTAssertEqual(streaks.longest, 450)
        XCTAssertEqual(streaks.trackedSince, trackedSince)
    }

    func test_streaks_areTheGapsBetweenShinies() {
        let streaks = DryStreaks(ledger: makeLedger(total: 450), catches: [makeCatch(atLedgerTotal: 100), makeCatch(atLedgerTotal: 400)])

        XCTAssertEqual(streaks.current, 50)
        XCTAssertEqual(streaks.longest, 300)
    }

    func test_theCurrentStreak_canBeTheLongest() {
        let streaks = DryStreaks(ledger: makeLedger(total: 900), catches: [makeCatch(atLedgerTotal: 100)])

        XCTAssertEqual(streaks.current, 800)
        XCTAssertEqual(streaks.longest, 800)
    }

    func test_streaks_followTheLedger_notTheCatchDates() {
        let catches = [
            makeCatch(atLedgerTotal: 400, on: makeDate(year: 2020, month: 1, day: 1)),
            makeCatch(atLedgerTotal: 100, on: makeDate(year: 2026, month: 1, day: 1))
        ]

        let streaks = DryStreaks(ledger: makeLedger(total: 450), catches: catches)

        XCTAssertEqual(streaks.current, 50)
        XCTAssertEqual(streaks.longest, 300)
    }

    func test_shiniesThatGotAway_endAStreakToo() {
        let streaks = DryStreaks(ledger: makeLedger(total: 300), catches: [makeCatch(atLedgerTotal: 250, isFailed: true)])

        XCTAssertEqual(streaks.current, 50)
        XCTAssertEqual(streaks.longest, 250)
    }

    func test_twoShiniesAtOnce_makeAnEmptyStreak_notANegativeOne() {
        let streaks = DryStreaks(ledger: makeLedger(total: 100), catches: [makeCatch(atLedgerTotal: 100), makeCatch(atLedgerTotal: 100)])

        XCTAssertEqual(streaks.current, 0)
        XCTAssertEqual(streaks.longest, 100)
    }

    func test_latestLedgerTotalAtFind_isTheHighest() {
        XCTAssertEqual(DryStreaks.findLatestLedgerTotalAtFind(in: [makeCatch(atLedgerTotal: 400), makeCatch(atLedgerTotal: nil), makeCatch(atLedgerTotal: 100)]), 400)
        XCTAssertNil(DryStreaks.findLatestLedgerTotalAtFind(in: [makeCatch(atLedgerTotal: nil)]))
    }

    // MARK: Yearly goal

    func test_goalProgress_countsEveryShinyFoundThatYear_includingOnesThatGotAway() {
        let catches = [
            makeCatch(atLedgerTotal: nil, on: makeDate(year: 2026, month: 1, day: 3)),
            makeCatch(atLedgerTotal: nil, on: makeDate(year: 2026, month: 5, day: 9), isFailed: true),
            makeCatch(atLedgerTotal: nil, on: makeDate(year: 2025, month: 12, day: 31)),
            makeCatch(atLedgerTotal: nil)
        ]

        let progress = YearlyGoalProgress(goal: YearlyGoal(year: 2026, target: 20), catches: catches, now: makeDate(year: 2026, month: 7, day: 2, hour: 12), calendar: calendar)

        XCTAssertEqual(progress.foundCount, 2)
        XCTAssertFalse(progress.isReached)
    }

    func test_goalPace_isTheShareOfTheTargetForTheTimeGone() {
        let goal = YearlyGoal(year: 2026, target: 20)
        let halfway = makeDate(year: 2026, month: 7, day: 2, hour: 12)

        let behind = YearlyGoalProgress(goal: goal, catches: [], now: halfway, calendar: calendar)
        XCTAssertEqual(behind.expectedByNow, 10)
        XCTAssertEqual(behind.aheadOfPace, -10)

        let ahead = YearlyGoalProgress(goal: goal, catches: (1...12).map { _ in makeCatch(atLedgerTotal: nil, on: makeDate(year: 2026, month: 2, day: 1)) }, now: halfway, calendar: calendar)
        XCTAssertEqual(ahead.aheadOfPace, 2)
    }

    func test_goalPace_isTheWholeTargetOnceTheYearIsOver_andNothingBeforeItStarts() {
        let goal = YearlyGoal(year: 2025, target: 8)

        XCTAssertEqual(YearlyGoalProgress(goal: goal, catches: [], now: makeDate(year: 2026, month: 3, day: 1), calendar: calendar).expectedByNow, 8)
        XCTAssertEqual(YearlyGoalProgress(goal: goal, catches: [], now: makeDate(year: 2024, month: 3, day: 1), calendar: calendar).expectedByNow, 0)
    }

    func test_goal_isReachedAtTheTarget() {
        let catches = (1...3).map { _ in makeCatch(atLedgerTotal: nil, on: makeDate(year: 2026, month: 2, day: 1)) }

        let progress = YearlyGoalProgress(goal: YearlyGoal(year: 2026, target: 3), catches: catches, now: makeDate(year: 2026, month: 3, day: 1), calendar: calendar)

        XCTAssertTrue(progress.isReached)
    }
}
