import Foundation

struct GetCatchStatisticsQuery {}

struct CatchStatistics: Equatable {
    struct Year: Equatable {
        let year: Int
        let foundCount: Int
        let averageEncounters: Int?
    }

    struct Luck: Equatable {
        let expectedShinies: Double
        let foundCount: Int
    }

    struct YearLuck: Equatable {
        let year: Int
        let luck: Luck
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

    struct Goal: Equatable {
        let target: Int
        let foundCount: Int
        let expectedByNow: Int
        let isReached: Bool
        let aheadOfPace: Int
    }

    struct Streaks: Equatable {
        let current: Int
        let longest: Int
        let trackedSince: Date
    }

    let currentYear: Int
    let encountersToday: Int
    let goal: Goal?
    let streaks: Streaks?
    let foundCount: Int
    let caughtCount: Int
    let failedCount: Int
    let catchRatePercent: Int?
    let caughtSpeciesCount: Int
    let totalEncounters: Int
    let catchesWithEncounters: Int
    let averageEncounters: Int?
    let years: [Year]
    let lifetimeLuck: Luck?
    let yearLuck: [YearLuck]
    let undatedCount: Int
    let months: [Period]
    let weekdays: [Period]
    let luckiestDates: [LuckyDate]
    let ballUsage: [Usage<String>]
    let gameUsage: [Usage<Games>]
    let methodUsage: [Usage<HuntMethod>]
    let natureUsage: [Usage<Nature>]
    let unknownNatureCount: Int
    var genderUsage: [Usage<Gender>] = []
    var unknownGenderCount = 0
    let shortestHunts: [CatchSummary]
    let longestHunts: [CatchSummary]
}

final class GetCatchStatisticsHandler {
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let ledgerRepository: EncounterLedgerRepository
    private let yearlyGoalRepository: YearlyGoalRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let calendar: Calendar
    private let genders: PokemonGenders
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, ledgerRepository: EncounterLedgerRepository, yearlyGoalRepository: YearlyGoalRepository,
         dailyEncountersRepository: DailyEncountersRepository, calendar: Calendar = .current, forms: PokemonForms = PokemonForms(), genders: PokemonGenders = PokemonGenders(),
         makeCurrentDate: @escaping () -> Date = Date.init) {
        self.forms = forms
        self.genders = genders
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.ledgerRepository = ledgerRepository
        self.yearlyGoalRepository = yearlyGoalRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetCatchStatisticsQuery) -> CatchStatistics {
        let catches = catchRepository.getAll()
        let stats = CatchStats(catches: catches, calendar: calendar, genders: genders)
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms, genders: genders)
        let now = makeCurrentDate()
        let currentYear = calendar.component(.year, from: now)
        return CatchStatistics(
            currentYear: currentYear,
            encountersToday: dailyEncountersRepository.get(day: EncounterDay(containing: now, calendar: calendar))?.count ?? 0,
            goal: makeGoal(for: currentYear, catches: catches, now: now),
            streaks: ledgerRepository.get().map { GetCatchStatisticsHandler.makeStreaks(DryStreaks(ledger: $0, catches: catches)) },
            foundCount: stats.foundCount,
            caughtCount: stats.caughtCount,
            failedCount: stats.failedCount,
            catchRatePercent: stats.catchRatePercent,
            caughtSpeciesCount: stats.caughtSpeciesCount,
            totalEncounters: stats.totalEncounters,
            catchesWithEncounters: stats.catchesWithEncounters,
            averageEncounters: stats.averageEncounters,
            years: stats.years.map { CatchStatistics.Year(year: $0.year, foundCount: $0.foundCount, averageEncounters: $0.averageEncounters) },
            lifetimeLuck: stats.lifetimeLuck.map(GetCatchStatisticsHandler.mapLuck),
            yearLuck: stats.yearLuck.map { CatchStatistics.YearLuck(year: $0.year, luck: GetCatchStatisticsHandler.mapLuck($0.luck)) },
            undatedCount: stats.undatedCount,
            months: stats.months.map { CatchStatistics.Period(period: $0.period, foundCount: $0.foundCount) },
            weekdays: stats.weekdays.map { CatchStatistics.Period(period: $0.period, foundCount: $0.foundCount) },
            luckiestDates: stats.luckiestDates.map { CatchStatistics.LuckyDate(month: $0.month, day: $0.day, foundCount: $0.foundCount) },
            ballUsage: stats.ballUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            gameUsage: stats.gameUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            methodUsage: stats.methodUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            natureUsage: stats.natureUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            unknownNatureCount: stats.unknownNatureCount,
            genderUsage: stats.genderUsage.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            unknownGenderCount: stats.unknownGenderCount,
            shortestHunts: stats.shortestHunts.compactMap(mapper.makeSummary),
            longestHunts: stats.longestHunts.compactMap(mapper.makeSummary))
    }

    private func makeGoal(for year: Int, catches: [Catch], now: Date) -> CatchStatistics.Goal? {
        guard let goal = yearlyGoalRepository.getAll().first(where: { $0.year == year }) else { return nil }
        let progress = YearlyGoalProgress(goal: goal, catches: catches, now: now, calendar: calendar)
        return CatchStatistics.Goal(target: goal.target, foundCount: progress.foundCount, expectedByNow: progress.expectedByNow,
                                    isReached: progress.isReached, aheadOfPace: progress.aheadOfPace)
    }

    private static func makeStreaks(_ streaks: DryStreaks) -> CatchStatistics.Streaks {
        return CatchStatistics.Streaks(current: streaks.current, longest: streaks.longest, trackedSince: streaks.trackedSince)
    }

    private static func mapLuck(_ luck: CatchStats.Luck) -> CatchStatistics.Luck {
        return CatchStatistics.Luck(expectedShinies: luck.expectedShinies, foundCount: luck.foundCount)
    }
}
