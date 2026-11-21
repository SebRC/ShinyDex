import Foundation

struct GetYearInReviewQuery {
    var year: Int?
}

struct YearInReview: Equatable {
    struct Goal: Equatable {
        let target: Int
        let foundCount: Int
        let isReached: Bool
    }

    struct BusiestDay: Equatable {
        let date: Date
        let encounters: Int
    }

    struct MonthCount: Equatable {
        let month: Int
        let count: Int
    }

    struct Hunt: Equatable {
        let caught: CatchSummary
        let percentChanceOfFindingSooner: Double
    }

    let year: Int
    let availableYears: [Int]
    let foundCount: Int
    let caughtCount: Int
    let failedCount: Int
    let caughtSpeciesCount: Int
    let trackedEncounters: Int?
    let encountersTrackedSince: Date?
    let busiestMonth: MonthCount?
    let busiestDay: BusiestDay?
    let goal: Goal?
    let firstShiny: CatchSummary?
    let latestShiny: CatchSummary?
    let luckiestHunt: Hunt?
    let unluckiestHunt: Hunt?
    let fullOddsLuck: CatchStatistics.Luck?
    let bestMonthForShinies: MonthCount?
    let favouriteGame: CatchStatistics.Usage<Games>?
    let topBalls: [CatchStatistics.Usage<String>]
    let favouriteMethod: CatchStatistics.Usage<HuntMethod>?
}

final class GetYearInReviewHandler {
    static let topBallCount = 3

    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let yearlyGoalRepository: YearlyGoalRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let forms: PokemonForms
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, yearlyGoalRepository: YearlyGoalRepository, dailyEncountersRepository: DailyEncountersRepository,
         forms: PokemonForms = PokemonForms(), calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.yearlyGoalRepository = yearlyGoalRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.forms = forms
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetYearInReviewQuery) -> YearInReview {
        let catches = catchRepository.getAll()
        let trackedDays = dailyEncountersRepository.getAll()
        let availableYears = findAvailableYears(catches: catches, trackedDays: trackedDays)
        let currentYear = calendar.component(.year, from: makeCurrentDate())
        let year = query.year ?? (availableYears.contains(currentYear) ? currentYear : availableYears.first ?? currentYear)

        let yearCatches = catches
            .filter { $0.caughtDate.map { calendar.component(.year, from: $0) } == year }
            .sorted { $0.caughtDate! < $1.caughtDate! }
        let stats = CatchStats(catches: yearCatches, calendar: calendar)
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        let yearDays = trackedDays.filter { $0.day.year == year }
        let huntsWithOdds = yearCatches.compactMap { caught in
            CatchOdds.calculateChanceOfFindingSooner(caught).map { (caught: caught, chance: $0) }
        }
        let luckiest = huntsWithOdds.min { $0.chance < $1.chance }
        let unluckiest = huntsWithOdds.count > 1 ? huntsWithOdds.max { $0.chance < $1.chance } : nil

        return YearInReview(
            year: year,
            availableYears: availableYears,
            foundCount: stats.foundCount,
            caughtCount: stats.caughtCount,
            failedCount: stats.failedCount,
            caughtSpeciesCount: stats.caughtSpeciesCount,
            trackedEncounters: yearDays.isEmpty ? nil : yearDays.reduce(0) { $0 + $1.count },
            encountersTrackedSince: findTrackingStart(in: year, trackedDays: trackedDays),
            busiestMonth: GetYearInReviewHandler.findBusiestMonth(in: yearDays),
            busiestDay: findBusiestDay(in: yearDays),
            goal: makeGoal(for: year, foundCount: stats.foundCount),
            firstShiny: yearCatches.first.flatMap(mapper.makeSummary),
            latestShiny: yearCatches.count > 1 ? yearCatches.last.flatMap(mapper.makeSummary) : nil,
            luckiestHunt: luckiest.flatMap { hunt in mapper.makeSummary(of: hunt.caught).map { YearInReview.Hunt(caught: $0, percentChanceOfFindingSooner: hunt.chance) } },
            unluckiestHunt: unluckiest.flatMap { hunt in mapper.makeSummary(of: hunt.caught).map { YearInReview.Hunt(caught: $0, percentChanceOfFindingSooner: hunt.chance) } },
            fullOddsLuck: stats.lifetimeLuck.map { CatchStatistics.Luck(expectedShinies: $0.expectedShinies, foundCount: $0.foundCount) },
            bestMonthForShinies: stats.months.filter { $0.foundCount > 0 }.max { $0.foundCount < $1.foundCount || ($0.foundCount == $1.foundCount && $0.period > $1.period) }
                .map { YearInReview.MonthCount(month: $0.period, count: $0.foundCount) },
            favouriteGame: stats.gameUsage.first.map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            topBalls: stats.ballUsage.prefix(GetYearInReviewHandler.topBallCount).map { CatchStatistics.Usage(key: $0.key, count: $0.count) },
            favouriteMethod: stats.methodUsage.first.map { CatchStatistics.Usage(key: $0.key, count: $0.count) })
    }

    private func findAvailableYears(catches: [Catch], trackedDays: [DailyEncounters]) -> [Int] {
        let catchYears = catches.compactMap { $0.caughtDate }.map { calendar.component(.year, from: $0) }
        let trackedYears = trackedDays.filter { $0.count > 0 }.map { $0.day.year }
        return Set(catchYears + trackedYears).sorted(by: >)
    }

    private func findTrackingStart(in year: Int, trackedDays: [DailyEncounters]) -> Date? {
        guard let firstDay = trackedDays.map({ $0.day }).min(), firstDay.year == year, (firstDay.month, firstDay.day) != (1, 1) else { return nil }
        return makeDate(firstDay)
    }

    private func findBusiestDay(in days: [DailyEncounters]) -> YearInReview.BusiestDay? {
        guard let busiest = days.filter({ $0.count > 0 }).max(by: { $0.count < $1.count || ($0.count == $1.count && $0.day < $1.day) }),
              let date = makeDate(busiest.day) else { return nil }
        return YearInReview.BusiestDay(date: date, encounters: busiest.count)
    }

    private func makeGoal(for year: Int, foundCount: Int) -> YearInReview.Goal? {
        guard let goal = yearlyGoalRepository.getAll().first(where: { $0.year == year }) else { return nil }
        return YearInReview.Goal(target: goal.target, foundCount: foundCount, isReached: foundCount >= goal.target)
    }

    private func makeDate(_ day: EncounterDay) -> Date? {
        return calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day))
    }

    private static func findBusiestMonth(in days: [DailyEncounters]) -> YearInReview.MonthCount? {
        let countsByMonth = Dictionary(days.map { ($0.day.month, $0.count) }, uniquingKeysWith: +).filter { $0.value > 0 }
        return countsByMonth
            .max { $0.value < $1.value || ($0.value == $1.value && $0.key > $1.key) }
            .map { YearInReview.MonthCount(month: $0.key, count: $0.value) }
    }
}
