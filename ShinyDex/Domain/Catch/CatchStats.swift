import Foundation

struct CatchStats {
    struct YearStat: Equatable {
        let year: Int
        let foundCount: Int
        let averageEncounters: Int?
    }

    struct YearLuck: Equatable {
        let year: Int
        let expectedShinies: Double
        let foundCount: Int
    }

    struct PeriodStat: Equatable {
        let period: Int
        let foundCount: Int
    }

    struct DateStat: Equatable {
        let month: Int
        let day: Int
        let foundCount: Int
    }

    struct Usage<Key: Hashable>: Equatable {
        let key: Key
        let count: Int
    }

    let foundCount: Int
    let caughtCount: Int
    let failedCount: Int
    let catchRatePercent: Int?
    let caughtSpeciesCount: Int
    let totalEncounters: Int
    let catchesWithEncounters: Int
    let averageEncounters: Int?
    let years: [YearStat]
    let yearLuck: [YearLuck]
    let undatedCount: Int
    let months: [PeriodStat]
    let weekdays: [PeriodStat]
    let luckiestDates: [DateStat]
    let ballUsage: [Usage<String>]
    let gameUsage: [Usage<Games>]
    let methodUsage: [Usage<HuntMethod>]
    let fastestCatch: Catch?
    let longestCatch: Catch?

    init(catches: [Catch], calendar: Calendar = .current) {
        let caught = catches.filter { !$0.isFailed }
        foundCount = catches.count
        caughtCount = caught.count
        failedCount = catches.count - caught.count
        catchRatePercent = catches.isEmpty ? nil : Int((Double(caught.count) / Double(catches.count) * 100).rounded())
        caughtSpeciesCount = Set(caught.map { $0.number }).count
        totalEncounters = catches.reduce(0) { $0 + $1.encounters }

        let withEncounters = catches.filter { $0.encounters > 0 }
        catchesWithEncounters = withEncounters.count
        averageEncounters = CatchStats.calculateAverage(of: withEncounters)

        let dated = catches.filter { $0.caughtDate != nil }
        undatedCount = catches.count - dated.count
        let byYear = Dictionary(grouping: dated) { calendar.component(.year, from: $0.caughtDate!) }
        years = byYear.keys.sorted().map { year in
            let yearCatches = byYear[year]!
            return YearStat(year: year,
                            foundCount: yearCatches.count,
                            averageEncounters: CatchStats.calculateAverage(of: yearCatches.filter { $0.encounters > 0 }))
        }

        yearLuck = byYear.keys.sorted().compactMap { year in
            CatchStats.calculateYearLuck(year, catches: byYear[year]!)
        }

        let dates = dated.map { $0.caughtDate! }
        months = CatchStats.countPeriods(of: dates, component: .month, periods: 1...12, calendar: calendar)
        weekdays = CatchStats.countPeriods(of: dates, component: .weekday, periods: 1...7, calendar: calendar)
        luckiestDates = CatchStats.findDatesWithMoreThanOneShiny(in: dates, calendar: calendar)

        ballUsage = CatchStats.countUsage(of: caught.map { $0.caughtBall }.filter { $0 != CatchRules.noBall }, name: { $0 })
        gameUsage = CatchStats.countUsage(of: caught.map { $0.game }, name: { $0.displayName })
        methodUsage = CatchStats.countUsage(of: caught.map { $0.huntMethod }, name: { $0.rawValue })

        fastestCatch = withEncounters.min { $0.encounters < $1.encounters }
        longestCatch = withEncounters.max { $0.encounters < $1.encounters }
    }

    fileprivate static func calculateAverage(of catches: [Catch]) -> Int? {
        guard !catches.isEmpty else { return nil }
        let total = catches.reduce(0) { $0 + $1.encounters }
        return Int((Double(total) / Double(catches.count)).rounded())
    }

    fileprivate static func calculateYearLuck(_ year: Int, catches: [Catch]) -> YearLuck? {
        let expectedPerCatch = catches.compactMap(calculateExpectedShinies)
        guard !expectedPerCatch.isEmpty else { return nil }
        return YearLuck(year: year, expectedShinies: expectedPerCatch.reduce(0, +), foundCount: expectedPerCatch.count)
    }

    fileprivate static func calculateExpectedShinies(from caught: Catch) -> Double? {
        guard caught.encounters > 0, let odds = CatchOdds.getOdds(for: caught) else { return nil }
        return Double(caught.encounters) / Double(odds)
    }

    fileprivate static func countPeriods(of dates: [Date], component: Calendar.Component, periods: ClosedRange<Int>, calendar: Calendar) -> [PeriodStat] {
        let counts = Dictionary(dates.map { (calendar.component(component, from: $0), 1) }, uniquingKeysWith: +)
        return periods.map { PeriodStat(period: $0, foundCount: counts[$0] ?? 0) }
    }

    fileprivate static func findDatesWithMoreThanOneShiny(in dates: [Date], calendar: Calendar) -> [DateStat] {
        let counts = Dictionary(dates.map { (calendar.dateComponents([.month, .day], from: $0), 1) }, uniquingKeysWith: +)
        return counts
            .filter { $0.value > 1 }
            .map { DateStat(month: $0.key.month!, day: $0.key.day!, foundCount: $0.value) }
            .sorted {
                if $0.foundCount != $1.foundCount { return $0.foundCount > $1.foundCount }
                return ($0.month, $0.day) < ($1.month, $1.day)
            }
    }

    fileprivate static func countUsage<Key: Hashable>(of keys: [Key], name: (Key) -> String) -> [Usage<Key>] {
        let counts = Dictionary(keys.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.map { Usage(key: $0.key, count: $0.value) }.sorted {
            $0.count != $1.count ? $0.count > $1.count : name($0.key) < name($1.key)
        }
    }
}
