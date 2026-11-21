import Foundation

struct ChooseBackupFolderCommand {
    let folderURL: URL
}

final class ChooseBackupFolderHandler {
    private let backupFolder: BackupFolder
    private let keyValueStore: KeyValueStore

    init(backupFolder: BackupFolder, keyValueStore: KeyValueStore) {
        self.backupFolder = backupFolder
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: ChooseBackupFolderCommand) throws {
        try backupFolder.choose(command.folderURL)
        keyValueStore.set(nil, forKey: AutomaticBackupKeys.lastBackupDate)
        keyValueStore.set(false, forKey: AutomaticBackupKeys.lastBackupFailed)
    }
}
