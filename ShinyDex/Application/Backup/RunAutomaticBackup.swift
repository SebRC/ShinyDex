import Foundation

struct RunAutomaticBackupCommand {
    var isForced = false
}

enum AutomaticBackupOutcome: Equatable {
    case notSetUp
    case notDue
    case backedUp
    case failed
}

enum AutomaticBackupKeys {
    static let lastBackupDate = "automaticBackupLastDate"
    static let lastBackupFailed = "automaticBackupLastFailed"
}

final class RunAutomaticBackupHandler {
    static let interval: TimeInterval = 7 * 24 * 60 * 60
    static let keptBackupCount = 5

    private let exportBackup: ExportBackupHandler
    private let backupFolder: BackupFolder
    private let keyValueStore: KeyValueStore
    private let makeCurrentDate: () -> Date

    init(exportBackup: ExportBackupHandler, backupFolder: BackupFolder, keyValueStore: KeyValueStore, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.exportBackup = exportBackup
        self.backupFolder = backupFolder
        self.keyValueStore = keyValueStore
        self.makeCurrentDate = makeCurrentDate
    }

    @discardableResult
    func handle(_ command: RunAutomaticBackupCommand) -> AutomaticBackupOutcome {
        guard backupFolder.name != nil else { return .notSetUp }
        let now = makeCurrentDate()
        if !command.isForced, let lastBackupDate = keyValueStore.getDate(forKey: AutomaticBackupKeys.lastBackupDate),
           now.timeIntervalSince(lastBackupDate) < RunAutomaticBackupHandler.interval {
            return .notDue
        }
        do {
            try backupFolder.write(try exportBackup.handle(ExportBackupQuery()))
            try removeOldBackups()
            keyValueStore.set(now, forKey: AutomaticBackupKeys.lastBackupDate)
            keyValueStore.set(false, forKey: AutomaticBackupKeys.lastBackupFailed)
            return .backedUp
        }
        catch {
            keyValueStore.set(true, forKey: AutomaticBackupKeys.lastBackupFailed)
            return .failed
        }
    }

    private func removeOldBackups() throws {
        let backupFileNames = try backupFolder.listFileNames()
            .filter(ExportBackupHandler.isBackupFileName)
            .sorted(by: >)
        for fileName in backupFileNames.dropFirst(RunAutomaticBackupHandler.keptBackupCount) {
            try backupFolder.deleteFile(named: fileName)
        }
    }
}
