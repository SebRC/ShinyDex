import Foundation

struct GetAchievementsQuery {}

struct AchievementsOverview: Equatable {
    let achievements: [Achievement]

    var unlockedCount: Int {
        return achievements.filter { $0.isUnlocked }.count
    }

    var unlockedTierCount: Int {
        return achievements.reduce(0) { $0 + $1.unlockedTierCount }
    }

    var tierCount: Int {
        return achievements.reduce(0) { $0 + $1.targets.count }
    }
}

final class GetAchievementsHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let huntRepository: HuntRepository
    private let yearlyGoalRepository: YearlyGoalRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let getJourneys: GetJourneysHandler
    private let getBingoBoards: GetBingoBoardsHandler
    private let getBallNames: GetBallNamesHandler
    private let getAutomaticBackupStatus: GetAutomaticBackupStatusHandler
    private let forms: PokemonForms
    private let evolutions: Evolutions
    private let moveCategories: MoveCategories
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, huntRepository: HuntRepository, yearlyGoalRepository: YearlyGoalRepository,
         dailyEncountersRepository: DailyEncountersRepository, getJourneys: GetJourneysHandler, getBingoBoards: GetBingoBoardsHandler, getBallNames: GetBallNamesHandler,
         getAutomaticBackupStatus: GetAutomaticBackupStatusHandler, forms: PokemonForms = PokemonForms(), evolutions: Evolutions = Evolutions(evolvesFrom: []),
         moveCategories: MoveCategories = MoveCategories(), calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.huntRepository = huntRepository
        self.yearlyGoalRepository = yearlyGoalRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.getJourneys = getJourneys
        self.getBingoBoards = getBingoBoards
        self.getBallNames = getBallNames
        self.getAutomaticBackupStatus = getAutomaticBackupStatus
        self.forms = forms
        self.evolutions = evolutions
        self.moveCategories = moveCategories
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetAchievementsQuery) -> AchievementsOverview {
        let today = EncounterDay(containing: makeCurrentDate(), calendar: calendar)
        let bingoBoards = getBingoBoards.handle(GetBingoBoardsQuery())
        var facts = AchievementFacts(catches: catchRepository.getAll())
        facts.encountersInProgress = pokemonRepository.getAll().reduce(0) { $0 + $1.encounters }
        facts.ballNames = getBallNames.handle(GetBallNamesQuery())
        facts.forms = forms
        facts.evolutions = evolutions
        facts.moveCategories = moveCategories
        facts.largestHuntSize = huntRepository.getAll().map { $0.indexes.count }.max() ?? 0
        facts.longestHuntingDayStreak = HuntingDayStreaks(days: dailyEncountersRepository.getAll(), today: today, calendar: calendar).longest
        facts.yearlyGoals = yearlyGoalRepository.getAll()
        facts.completedJourneyCount = getJourneys.handle(GetJourneysQuery()).filter { $0.isComplete }.count
        facts.completedBingoLineCount = bingoBoards.reduce(0) { $0 + $1.completedLineCount }
        facts.blackoutBoardCount = bingoBoards.filter { $0.isBlackout }.count
        facts.hasAutomaticBackups = getAutomaticBackupStatus.handle(GetAutomaticBackupStatusQuery()).isOn
        facts.calendar = calendar
        return AchievementsOverview(achievements: AchievementRules.evaluate(facts))
    }
}
