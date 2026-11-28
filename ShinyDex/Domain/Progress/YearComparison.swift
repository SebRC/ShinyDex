import Foundation

struct YearComparison: Equatable {
    struct Month: Equatable {
        let month: Int
        let shinies: Int
        let previousShinies: Int
        let encounters: Int
        let previousEncounters: Int
        let isUpcoming: Bool
    }

    struct Pace: Equatable {
        let current: Int
        let previous: Int

        var difference: Int {
            return current - previous
        }
    }

    let year: Int
    let months: [Month]
    let shinies: Pace
    let encounters: Pace
    let cutoffMonth: Int
    let cutoffDay: Int

    var previousYear: Int {
        return year - 1
    }

    init(year: Int, catchDates: [Date], days: [DailyEncounters], today: EncounterDay, calendar: Calendar) {
        self.year = year
        let isCurrentYear = year == today.year
        let cutoffMonth = isCurrentYear ? today.month : 12
        let cutoffDay = isCurrentYear ? today.day : 31
        self.cutoffMonth = cutoffMonth
        self.cutoffDay = cutoffDay
        let catchDays = catchDates.map { EncounterDay(containing: $0, calendar: calendar) }
        let shiniesByMonth = YearComparison.countByMonth(catchDays.map { ($0, 1) }, in: year)
        let previousShiniesByMonth = YearComparison.countByMonth(catchDays.map { ($0, 1) }, in: year - 1)
        let encountersByMonth = YearComparison.countByMonth(days.map { ($0.day, $0.count) }, in: year)
        let previousEncountersByMonth = YearComparison.countByMonth(days.map { ($0.day, $0.count) }, in: year - 1)
        months = (1...12).map { month in
            Month(month: month, shinies: shiniesByMonth[month] ?? 0, previousShinies: previousShiniesByMonth[month] ?? 0,
                  encounters: encountersByMonth[month] ?? 0, previousEncounters: previousEncountersByMonth[month] ?? 0,
                  isUpcoming: month > cutoffMonth)
        }
        let isWithinCutoff = { (day: EncounterDay) in (day.month, day.day) <= (cutoffMonth, cutoffDay) }
        shinies = Pace(current: catchDays.filter { $0.year == year && isWithinCutoff($0) }.count,
                       previous: catchDays.filter { $0.year == year - 1 && isWithinCutoff($0) }.count)
        encounters = Pace(current: days.filter { $0.day.year == year && isWithinCutoff($0.day) }.reduce(0) { $0 + $1.count },
                          previous: days.filter { $0.day.year == year - 1 && isWithinCutoff($0.day) }.reduce(0) { $0 + $1.count })
    }

    private static func countByMonth(_ counts: [(day: EncounterDay, count: Int)], in year: Int) -> [Int: Int] {
        return Dictionary(counts.filter { $0.day.year == year }.map { ($0.day.month, $0.count) }, uniquingKeysWith: +)
    }
}
