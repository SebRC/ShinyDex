import Foundation

enum EncounterPeriod: CaseIterable {
    case day, month, year
}

struct GetEncounterHistoryQuery {
    var period = EncounterPeriod.day
}

struct EncounterHistory: Equatable {
    struct Entry: Equatable {
        let start: Date
        let count: Int
    }

    struct DayStreaks: Equatable {
        let current: Int
        let longest: Int
    }

    let period: EncounterPeriod
    let recent: [Entry]
    let recorded: [Entry]
    let busiest: Entry?
    let averagePerActivePeriod: Int?
    let trackedSince: Date?
    let dayStreaks: DayStreaks
    let calendarWeeks: [[Entry?]]
}

final class GetEncounterHistoryHandler {
    static let recentDayCount = 30
    static let recentMonthCount = 12
    static let calendarWeekCount = 26

    private let dailyEncountersRepository: DailyEncountersRepository
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(dailyEncountersRepository: DailyEncountersRepository, calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.dailyEncountersRepository = dailyEncountersRepository
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetEncounterHistoryQuery) -> EncounterHistory {
        let storedDays = dailyEncountersRepository.getAll()
        let trackedDays = storedDays.compactMap { encounters in
            makeStartOfDay(encounters.day).map { EncounterHistory.Entry(start: $0, count: encounters.count) }
        }
        let component = GetEncounterHistoryHandler.makeCalendarComponent(for: query.period)
        let countsByPeriodStart = Dictionary(trackedDays.map { (findStart(of: component, containing: $0.start), $0.count) }, uniquingKeysWith: +)
        let recorded = countsByPeriodStart
            .filter { $0.value > 0 }
            .map { EncounterHistory.Entry(start: $0.key, count: $0.value) }
            .sorted { $0.start > $1.start }
        let trackedSince = trackedDays.map { $0.start }.min()
        let streaks = HuntingDayStreaks(days: storedDays, today: EncounterDay(containing: makeCurrentDate(), calendar: calendar), calendar: calendar)
        let countsByDay = Dictionary(trackedDays.map { ($0.start, $0.count) }, uniquingKeysWith: +)
        return EncounterHistory(period: query.period,
                                recent: makeRecent(of: query.period, countsByPeriodStart: countsByPeriodStart, trackedSince: trackedSince),
                                recorded: recorded,
                                busiest: recorded.max { $0.count < $1.count || ($0.count == $1.count && $0.start < $1.start) },
                                averagePerActivePeriod: GetEncounterHistoryHandler.calculateAverage(of: recorded),
                                trackedSince: trackedSince,
                                dayStreaks: EncounterHistory.DayStreaks(current: streaks.current, longest: streaks.longest),
                                calendarWeeks: makeCalendarWeeks(countsByDay: countsByDay))
    }

    private func makeCalendarWeeks(countsByDay: [Date: Int]) -> [[EncounterHistory.Entry?]] {
        let today = calendar.startOfDay(for: makeCurrentDate())
        let currentWeekStart = findStart(of: .weekOfYear, containing: today)
        let weekCount = GetEncounterHistoryHandler.calendarWeekCount
        guard let firstWeekStart = calendar.date(byAdding: .day, value: -7 * (weekCount - 1), to: currentWeekStart) else { return [] }
        return (0..<weekCount).map { week in
            (0..<7).map { weekday in
                guard let date = calendar.date(byAdding: .day, value: week * 7 + weekday, to: firstWeekStart), date <= today else { return nil }
                return EncounterHistory.Entry(start: date, count: countsByDay[date] ?? 0)
            }
        }
    }

    private func makeRecent(of period: EncounterPeriod, countsByPeriodStart: [Date: Int], trackedSince: Date?) -> [EncounterHistory.Entry] {
        let component = GetEncounterHistoryHandler.makeCalendarComponent(for: period)
        let currentStart = findStart(of: component, containing: makeCurrentDate())
        let periodCount: Int
        switch period {
        case .day: periodCount = GetEncounterHistoryHandler.recentDayCount
        case .month: periodCount = GetEncounterHistoryHandler.recentMonthCount
        case .year: periodCount = 1 + countYears(from: trackedSince, to: currentStart)
        }
        return (0..<periodCount).reversed().compactMap { periodsAgo in
            guard let start = calendar.date(byAdding: component, value: -periodsAgo, to: currentStart) else { return nil }
            return EncounterHistory.Entry(start: start, count: countsByPeriodStart[start] ?? 0)
        }
    }

    private func countYears(from trackedSince: Date?, to currentYearStart: Date) -> Int {
        guard let trackedSince = trackedSince else { return 0 }
        let firstYearStart = findStart(of: .year, containing: trackedSince)
        return max(calendar.dateComponents([.year], from: firstYearStart, to: currentYearStart).year ?? 0, 0)
    }

    private func findStart(of component: Calendar.Component, containing date: Date) -> Date {
        return calendar.dateInterval(of: component, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func makeStartOfDay(_ day: EncounterDay) -> Date? {
        return day.makeDate(in: calendar).map(calendar.startOfDay)
    }

    private static func makeCalendarComponent(for period: EncounterPeriod) -> Calendar.Component {
        switch period {
        case .day: return .day
        case .month: return .month
        case .year: return .year
        }
    }

    private static func calculateAverage(of entries: [EncounterHistory.Entry]) -> Int? {
        guard !entries.isEmpty else { return nil }
        return Int((Double(entries.map { $0.count }.reduce(0, +)) / Double(entries.count)).rounded())
    }
}
