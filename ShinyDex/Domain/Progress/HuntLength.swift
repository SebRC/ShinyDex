import Foundation

struct HuntLength: Equatable {
    let days: Int
    let activeDays: Int

    init?(of number: Int, endingOn end: EncounterDay, after previousFind: EncounterDay?, days trackedDays: [DailyEncounters], calendar: Calendar) {
        let huntedDays = trackedDays
            .filter { tracked in (tracked.countsByPokemon[number] ?? 0) > 0 && tracked.day <= end && previousFind.map { tracked.day > $0 } ?? true }
            .map { $0.day }
        guard let first = huntedDays.min(), let firstDate = first.makeDate(in: calendar), let endDate = end.makeDate(in: calendar),
              let span = calendar.dateComponents([.day], from: firstDate, to: endDate).day else { return nil }
        days = span + 1
        activeDays = Set(huntedDays).count
    }
}
