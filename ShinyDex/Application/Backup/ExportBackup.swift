import Foundation

struct ExportBackupQuery {}

final class ExportBackupHandler {
    static let backupFileNamePrefix = "ShinyDex Backup "

    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let huntRepository: HuntRepository
    private let journeyRepository: JourneyRepository
    private let bingoBoardRepository: BingoBoardRepository
    private let moveRepository: MoveRepository
    private let ledgerRepository: EncounterLedgerRepository
    private let yearlyGoalRepository: YearlyGoalRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let teamRepository: TeamRepository
    private let makeCurrentDate: () -> Date

    init(pokemonRepository: PokemonRepository, catchRepository: CatchRepository, huntRepository: HuntRepository, journeyRepository: JourneyRepository,
         bingoBoardRepository: BingoBoardRepository, moveRepository: MoveRepository, ledgerRepository: EncounterLedgerRepository,
         yearlyGoalRepository: YearlyGoalRepository, dailyEncountersRepository: DailyEncountersRepository, teamRepository: TeamRepository, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        self.huntRepository = huntRepository
        self.journeyRepository = journeyRepository
        self.bingoBoardRepository = bingoBoardRepository
        self.moveRepository = moveRepository
        self.ledgerRepository = ledgerRepository
        self.yearlyGoalRepository = yearlyGoalRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.teamRepository = teamRepository
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: ExportBackupQuery) throws -> BackupFile {
        let createdDate = makeCurrentDate()
        let document = BackupDocument(
            pokemon: pokemonRepository.getAll(),
            catches: catchRepository.getAll(),
            hunts: huntRepository.getAll(),
            journeys: journeyRepository.getAll(),
            bingoBoards: bingoBoardRepository.getAll(),
            activeMoves: moveRepository.getActiveMoves(),
            encounterLedger: ledgerRepository.get(),
            yearlyGoals: yearlyGoalRepository.getAll(),
            dailyEncounters: dailyEncountersRepository.getAll(),
            teams: teamRepository.getAll(),
            createdDate: createdDate)
        return BackupFile(fileName: ExportBackupHandler.makeFileName(for: createdDate), data: try document.encode())
    }

    static func isBackupFileName(_ fileName: String) -> Bool {
        return fileName.hasPrefix(backupFileNamePrefix) && fileName.hasSuffix(".json")
    }

    static func makeFileName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(backupFileNamePrefix)\(formatter.string(from: date)).json"
    }
}
