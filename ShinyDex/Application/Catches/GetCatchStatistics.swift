import Foundation

struct GetCatchStatisticsQuery {}

struct CatchStatistics: Equatable {
    struct Year: Equatable {
        let year: Int
        let foundCount: Int
        let averageEncounters: Int?
    }

    struct Period: Equatable {
        let period: Int
        let foundCount: Int
    }

    struct LuckyDate: Equatable {
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
    let years: [Year]
    let undatedCount: Int
    let months: [Period]
    let weekdays: [Period]
    let luckiestDates: [LuckyDate]
    let ballUsage: [Usage<String>]
    let gameUsage: [Usage<Games>]
    let methodUsage: [Usage<HuntMethod>]
    let fastestCatch: CatchSummary?
    let longestCatch: CatchSummary?
}

final class GetCatchStatisticsHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let calendar: Calendar

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, calendar: Calendar = .current) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.calendar = calendar
    }

    func handle(_ query: GetCatchStatisticsQuery) -> CatchStatistics {
        let stats = CatchStats(catches: catchRepository.getAll(), calendar: calendar)
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll())
        return CatchStatistics(
            foundCount: stats.foundCount,
            caughtCount: stats.caughtCount,
            failedCount: stats.failedCount,
            catchRatePercent: stats.catchRatePercent,
            caughtSpeciesCount: stats.caughtSpeciesCount,
            totalEncounters: stats.totalEncounters,
            catchesWithEncounters: stats.catchesWithEncounters,
            averageEncounters: stats.averageEncounters,
            years: stats.years.map { CatchStatistics.Year(year: $0.year, foundCount: $0.foundCount, averageEncounters: $0.averageEncounters) },
            undatedCount: stats.undatedCount,
            months: stats.months.map { CatchStatistics.Period(period: $0.period, foundCount: $0.foundCount) },
            weekdays: stats.weekdays.map { CatchStatistics.Period(period: $0.period, foundCount: $0.foundCount) },
            luckiestDates: stats.luckiestDates.map { CatchStatistics.LuckyDate(month: $0.month, day: $0.day, foundCount: $0.foundCount) },
            ballUsage: stats.ballUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            gameUsage: stats.gameUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            methodUsage: stats.methodUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            fastestCatch: stats.fastestCatch.flatMap(mapper.summary),
            longestCatch: stats.longestCatch.flatMap(mapper.summary))
    }
}
