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

    let period: EncounterPeriod
    let recent: [Entry]
    let recorded: [Entry]
    let busiest: Entry?
    let averagePerActivePeriod: Int?
    let trackedSince: Date?
}

final class GetEncounterHistoryHandler {
    static let recentDayCount = 30
    static let recentMonthCount = 12

    private let dailyEncountersRepository: DailyEncountersRepository
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(dailyEncountersRepository: DailyEncountersRepository, calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.dailyEncountersRepository = dailyEncountersRepository
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetEncounterHistoryQuery) -> EncounterHistory {
        let trackedDays = dailyEncountersRepository.getAll().compactMap { encounters in
            makeStartOfDay(encounters.day).map { EncounterHistory.Entry(start: $0, count: encounters.count) }
        }
        let component = GetEncounterHistoryHandler.makeCalendarComponent(for: query.period)
        let countsByPeriodStart = Dictionary(trackedDays.map { (findStart(of: component, containing: $0.start), $0.count) }, uniquingKeysWith: +)
        let recorded = countsByPeriodStart
            .filter { $0.value > 0 }
            .map { EncounterHistory.Entry(start: $0.key, count: $0.value) }
            .sorted { $0.start > $1.start }
        let trackedSince = trackedDays.map { $0.start }.min()
        return EncounterHistory(period: query.period,
                                recent: makeRecent(of: query.period, countsByPeriodStart: countsByPeriodStart, trackedSince: trackedSince),
                                recorded: recorded,
                                busiest: recorded.max { $0.count < $1.count || ($0.count == $1.count && $0.start < $1.start) },
                                averagePerActivePeriod: GetEncounterHistoryHandler.calculateAverage(of: recorded),
                                trackedSince: trackedSince)
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
        return calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day)).map(calendar.startOfDay)
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
