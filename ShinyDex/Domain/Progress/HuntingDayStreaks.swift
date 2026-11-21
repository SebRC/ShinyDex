import Foundation

struct HuntingDayStreaks: Equatable {
    let current: Int
    let longest: Int

    init(days: [DailyEncounters], today: EncounterDay, calendar: Calendar) {
        let huntedDays = Set(days.filter { $0.count > 0 }.map { $0.day })
        let streakEnd = huntedDays.contains(today) ? today : today.adding(days: -1, calendar: calendar)
        current = HuntingDayStreaks.countRun(endingOn: streakEnd, in: huntedDays, calendar: calendar)
        longest = huntedDays
            .filter { !huntedDays.contains($0.adding(days: 1, calendar: calendar)) }
            .map { HuntingDayStreaks.countRun(endingOn: $0, in: huntedDays, calendar: calendar) }
            .max() ?? 0
    }

    private static func countRun(endingOn lastDay: EncounterDay, in huntedDays: Set<EncounterDay>, calendar: Calendar) -> Int {
        var length = 0
        var day = lastDay
        while huntedDays.contains(day) {
            length += 1
            day = day.adding(days: -1, calendar: calendar)
        }
        return length
    }
}
