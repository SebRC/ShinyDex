import Foundation

struct GetEncounterHistoryQuery {
    var recentDayCount = 30
}

struct EncounterHistory: Equatable {
    struct Day: Equatable {
        let date: Date
        let count: Int
    }

    let recentDays: [Day]
    let recordedDays: [Day]
    let busiestDay: Day?
    let averagePerActiveDay: Int?
}

final class GetEncounterHistoryHandler {
    private let dailyEncountersRepository: DailyEncountersRepository
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(dailyEncountersRepository: DailyEncountersRepository, calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.dailyEncountersRepository = dailyEncountersRepository
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetEncounterHistoryQuery) -> EncounterHistory {
        let activeDays = dailyEncountersRepository.getAll()
            .filter { $0.count > 0 }
            .sorted { $0.day > $1.day }
            .compactMap(makeHistoryDay)
        let busiestDay = activeDays.max { $0.count < $1.count || ($0.count == $1.count && $0.date < $1.date) }
        let averagePerActiveDay = activeDays.isEmpty ? nil : Int((Double(activeDays.map { $0.count }.reduce(0, +)) / Double(activeDays.count)).rounded())
        return EncounterHistory(recentDays: makeRecentDays(count: query.recentDayCount, activeDays: activeDays),
                                recordedDays: activeDays,
                                busiestDay: busiestDay,
                                averagePerActiveDay: averagePerActiveDay)
    }

    private func makeRecentDays(count: Int, activeDays: [EncounterHistory.Day]) -> [EncounterHistory.Day] {
        let today = calendar.startOfDay(for: makeCurrentDate())
        let countsByDate = Dictionary(activeDays.map { ($0.date, $0.count) }, uniquingKeysWith: +)
        return (0..<max(count, 0)).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            return EncounterHistory.Day(date: date, count: countsByDate[date] ?? 0)
        }
    }

    private func makeHistoryDay(_ encounters: DailyEncounters) -> EncounterHistory.Day? {
        let components = DateComponents(year: encounters.day.year, month: encounters.day.month, day: encounters.day.day)
        guard let date = calendar.date(from: components) else { return nil }
        return EncounterHistory.Day(date: calendar.startOfDay(for: date), count: encounters.count)
    }
}
