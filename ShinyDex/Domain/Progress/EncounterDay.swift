import Foundation

struct EncounterDay: Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(containing date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
    }

    init?(isoDate: String?) {
        let parts = (isoDate ?? "").split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    func makeDate(in calendar: Calendar) -> Date? {
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    func adding(days: Int, calendar: Calendar) -> EncounterDay {
        guard let date = makeDate(in: calendar), let shifted = calendar.date(byAdding: .day, value: days, to: date) else { return self }
        return EncounterDay(containing: shifted, calendar: calendar)
    }

    var isoDate: String {
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func < (lhs: EncounterDay, rhs: EncounterDay) -> Bool {
        return (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

struct DailyEncounters: Equatable {
    let day: EncounterDay
    private(set) var count: Int

    init(day: EncounterDay, count: Int) {
        self.day = day
        self.count = max(count, 0)
    }

    mutating func record(_ change: Int) {
        count = max(count + change, 0)
    }
}
