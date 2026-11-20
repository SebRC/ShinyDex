import Foundation

enum BackupRestoreError: Error {
    case saveFailed
}

protocol BackupRepository {
    func replaceAll(with backup: Backup) throws
}
