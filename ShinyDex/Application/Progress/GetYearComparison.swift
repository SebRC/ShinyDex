import Foundation

struct GetYearComparisonQuery {
    var year: Int?
}

struct YearOnYear: Equatable {
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
        let difference: Int
    }

    let year: Int
    let previousYear: Int
    let availableYears: [Int]
    let months: [Month]
    let shinies: Pace
    let encounters: Pace
    let comparedUntil: Date
    let isFullYear: Bool
    let encountersTrackedSince: Date?
}

final class GetYearComparisonHandler {
    private let catchRepository: CatchRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, dailyEncountersRepository: DailyEncountersRepository, calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.catchRepository = catchRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetYearComparisonQuery) -> YearOnYear {
        let catchDates = catchRepository.getAll().compactMap { $0.caughtDate }
        let days = dailyEncountersRepository.getAll()
        let today = EncounterDay(containing: makeCurrentDate(), calendar: calendar)
        let year = query.year ?? today.year
        let comparison = YearComparison(year: year, catchDates: catchDates, days: days, today: today, calendar: calendar)
        let comparedUntil = EncounterDay(year: year, month: comparison.cutoffMonth, day: comparison.cutoffDay).makeDate(in: calendar) ?? makeCurrentDate()
        return YearOnYear(
            year: year,
            previousYear: comparison.previousYear,
            availableYears: findAvailableYears(catchDates: catchDates, days: days, currentYear: today.year),
            months: comparison.months.map {
                YearOnYear.Month(month: $0.month, shinies: $0.shinies, previousShinies: $0.previousShinies, encounters: $0.encounters,
                                 previousEncounters: $0.previousEncounters, isUpcoming: $0.isUpcoming)
            },
            shinies: makePace(comparison.shinies),
            encounters: makePace(comparison.encounters),
            comparedUntil: comparedUntil,
            isFullYear: year != today.year,
            encountersTrackedSince: findTrackingStart(in: days, comparing: year))
    }

    private func findAvailableYears(catchDates: [Date], days: [DailyEncounters], currentYear: Int) -> [Int] {
        let catchYears = catchDates.map { calendar.component(.year, from: $0) }
        let trackedYears = days.filter { $0.count > 0 }.map { $0.day.year }
        return Set(catchYears + trackedYears + [currentYear]).filter { $0 <= currentYear }.sorted(by: >)
    }

    private func findTrackingStart(in days: [DailyEncounters], comparing year: Int) -> Date? {
        guard let firstDay = days.filter({ $0.count > 0 }).map({ $0.day }).min(),
              firstDay > EncounterDay(year: year - 1, month: 1, day: 1) else { return nil }
        return firstDay.makeDate(in: calendar)
    }

    private func makePace(_ pace: YearComparison.Pace) -> YearOnYear.Pace {
        return YearOnYear.Pace(current: pace.current, previous: pace.previous, difference: pace.difference)
    }
}
