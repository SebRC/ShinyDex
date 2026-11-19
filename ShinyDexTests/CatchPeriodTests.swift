import XCTest
@testable import ShinyDex

class CatchPeriodTests: XCTestCase {
	fileprivate var calendar: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		return calendar
	}

	fileprivate func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
		return calendar.date(from: DateComponents(year: year, month: month, day: day))!
	}

	func test_year_matchesDatesInThatYearOnly() {
		XCTAssertTrue(CatchPeriod.year(2024).contains(date(2024, 1, 1), calendar: calendar))
		XCTAssertTrue(CatchPeriod.year(2024).contains(date(2024, 12, 31), calendar: calendar))
		XCTAssertFalse(CatchPeriod.year(2024).contains(date(2023, 12, 31), calendar: calendar))
	}

	func test_date_matchesTheCalendarDateAcrossYears() {
		let march14 = CatchPeriod.date(month: 3, day: 14)

		XCTAssertTrue(march14.contains(date(2025, 3, 14), calendar: calendar))
		XCTAssertTrue(march14.contains(date(2022, 3, 14), calendar: calendar))
		XCTAssertFalse(march14.contains(date(2022, 3, 15), calendar: calendar))
		XCTAssertFalse(march14.contains(date(2022, 4, 14), calendar: calendar))
	}

	func test_monthAndWeekday_matchAcrossYears() {
		let sunday = date(2024, 3, 3)
		let monday = date(2023, 3, 6)

		XCTAssertTrue(CatchPeriod.month(3).contains(sunday, calendar: calendar))
		XCTAssertTrue(CatchPeriod.month(3).contains(monday, calendar: calendar))
		XCTAssertFalse(CatchPeriod.month(3).contains(date(2024, 4, 1), calendar: calendar))
		XCTAssertTrue(CatchPeriod.weekday(1).contains(sunday, calendar: calendar))
		XCTAssertFalse(CatchPeriod.weekday(1).contains(monday, calendar: calendar))
	}
}
