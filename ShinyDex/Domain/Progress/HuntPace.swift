import Foundation

struct HuntPace: Equatable {
    static let windowDays = 14

    let encountersPerDay: Int
    let activeDays: Int

    init?(number: Int, dailyEncounters: [DailyEncounters], today: EncounterDay, calendar: Calendar) {
        let firstDay = today.adding(days: -(HuntPace.windowDays - 1), calendar: calendar)
        let counts = dailyEncounters
            .filter { $0.day >= firstDay && $0.day <= today }
            .compactMap { $0.countsByPokemon[number] }
            .filter { $0 > 0 }
        guard !counts.isEmpty else { return nil }
        activeDays = counts.count
        encountersPerDay = max(Int((Double(counts.reduce(0, +)) / Double(counts.count)).rounded()), 1)
    }

    func estimateDays(toCover remainingEncounters: Int) -> Int? {
        guard remainingEncounters > 0 else { return nil }
        return Int((Double(remainingEncounters) / Double(encountersPerDay)).rounded(.up))
    }
}
