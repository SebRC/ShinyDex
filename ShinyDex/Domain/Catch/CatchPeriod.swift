import Foundation

enum CatchPeriod: Equatable {
	case year(Int)
	case month(Int)
	case monthOfYear(month: Int, year: Int)
	case weekday(Int)
	case date(month: Int, day: Int)

	func contains(_ date: Date, calendar: Calendar) -> Bool {
		switch self {
		case .year(let year):
			return calendar.component(.year, from: date) == year
		case .month(let month):
			return calendar.component(.month, from: date) == month
		case let .monthOfYear(month, year):
			let components = calendar.dateComponents([.year, .month], from: date)
			return components.month == month && components.year == year
		case .weekday(let weekday):
			return calendar.component(.weekday, from: date) == weekday
		case let .date(month, day):
			let components = calendar.dateComponents([.month, .day], from: date)
			return components.month == month && components.day == day
		}
	}
}
