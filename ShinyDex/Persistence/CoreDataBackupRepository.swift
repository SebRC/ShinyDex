import CoreData

final class CoreDataBackupRepository: BackupRepository {
    private let managedContext: NSManagedObjectContext

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }

    func replaceAll(with backup: Backup) throws {
        let stagingContext = makeStagingContext()
        do {
            try stage(backup, in: stagingContext)
            try managedContext.save()
        }
        catch {
            stagingContext.reset()
            managedContext.rollback()
            throw BackupRestoreError.saveFailed
        }
    }

    private func makeStagingContext() -> NSManagedObjectContext {
        let stagingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        stagingContext.parent = managedContext
        return stagingContext
    }

    private func stage(_ backup: Backup, in context: NSManagedObjectContext) throws {
        try stageCatches(backup.catches, in: context)
        stageHunts(backup.hunts, in: context)
        try stageJourneys(backup.journeys, in: context)
        try stageBingoBoards(backup.bingoBoards, in: context)
        let pokemonRepository = CoreDataPokemonRepository(managedContext: context)
        backup.pokemon.forEach(pokemonRepository.save)
        if let activeMoves = backup.activeMoves {
            CoreDataMoveRepository(managedContext: context).save(activeMoves)
        }
        if let encounterLedger = backup.encounterLedger {
            CoreDataEncounterLedgerRepository(managedContext: context).save(encounterLedger)
        }
        if let yearlyGoals = backup.yearlyGoals {
            stageYearlyGoals(yearlyGoals, in: context)
        }
        if context.hasChanges {
            try context.save()
        }
    }

    private func stageCatches(_ catches: [Catch], in context: NSManagedObjectContext) throws {
        let repository = CoreDataCatchRepository(managedContext: context)
        let restoredIds = Set(catches.map { $0.id })
        let existing = repository.getAll()
        let existingIds = Set(existing.map { $0.id })
        existing.filter { !restoredIds.contains($0.id) }.forEach(repository.delete)
        for caught in catches {
            if existingIds.contains(caught.id) {
                repository.update(caught)
            }
            else {
                repository.insert(caught)
            }
        }
        guard repository.save() else { throw BackupRestoreError.saveFailed }
    }

    private func stageHunts(_ hunts: [Hunt], in context: NSManagedObjectContext) {
        let repository = CoreDataHuntRepository(managedContext: context)
        let restoredIds = Set(hunts.map { $0.id })
        repository.getAll().filter { !restoredIds.contains($0.id) }.forEach(repository.delete)
        hunts.forEach(repository.save)
    }

    private func stageJourneys(_ journeys: [Journey], in context: NSManagedObjectContext) throws {
        let repository = CoreDataJourneyRepository(managedContext: context)
        let restoredIds = Set(journeys.map { $0.id })
        repository.getAll().filter { !restoredIds.contains($0.id) }.forEach(repository.delete)
        for journey in journeys {
            guard repository.save(journey) else { throw BackupRestoreError.saveFailed }
        }
    }

    private func stageYearlyGoals(_ goals: [YearlyGoal], in context: NSManagedObjectContext) {
        let repository = CoreDataYearlyGoalRepository(managedContext: context)
        let restoredYears = Set(goals.map { $0.year })
        repository.getAll().filter { !restoredYears.contains($0.year) }.forEach { repository.delete(year: $0.year) }
        goals.forEach(repository.save)
    }

    private func stageBingoBoards(_ boards: [BingoBoard], in context: NSManagedObjectContext) throws {
        let repository = CoreDataBingoBoardRepository(managedContext: context)
        let restoredIds = Set(boards.map { $0.id })
        repository.getAll().filter { !restoredIds.contains($0.id) }.forEach(repository.delete)
        for board in boards {
            guard repository.save(board) else { throw BackupRestoreError.saveFailed }
        }
    }
}
