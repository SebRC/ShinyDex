import Foundation

struct GetAutomaticBackupStatusQuery {}

struct AutomaticBackupStatus: Equatable {
    let folderName: String?
    let lastBackupDate: Date?
    let lastBackupFailed: Bool

    var isOn: Bool {
        return folderName != nil
    }
}

final class GetAutomaticBackupStatusHandler {
    private let backupFolder: BackupFolder
    private let keyValueStore: KeyValueStore

    init(backupFolder: BackupFolder, keyValueStore: KeyValueStore) {
        self.backupFolder = backupFolder
        self.keyValueStore = keyValueStore
    }

    func handle(_ query: GetAutomaticBackupStatusQuery) -> AutomaticBackupStatus {
        return AutomaticBackupStatus(folderName: backupFolder.name,
                                     lastBackupDate: keyValueStore.getDate(forKey: AutomaticBackupKeys.lastBackupDate),
                                     lastBackupFailed: keyValueStore.getBool(forKey: AutomaticBackupKeys.lastBackupFailed))
    }
}
