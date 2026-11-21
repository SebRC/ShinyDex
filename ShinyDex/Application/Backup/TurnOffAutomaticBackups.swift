import Foundation

struct TurnOffAutomaticBackupsCommand {}

final class TurnOffAutomaticBackupsHandler {
    private let backupFolder: BackupFolder
    private let keyValueStore: KeyValueStore

    init(backupFolder: BackupFolder, keyValueStore: KeyValueStore) {
        self.backupFolder = backupFolder
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: TurnOffAutomaticBackupsCommand) {
        backupFolder.forget()
        keyValueStore.set(nil, forKey: AutomaticBackupKeys.lastBackupDate)
        keyValueStore.set(false, forKey: AutomaticBackupKeys.lastBackupFailed)
    }
}
