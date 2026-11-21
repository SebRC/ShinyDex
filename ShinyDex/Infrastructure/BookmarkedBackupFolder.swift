import Foundation

enum BackupFolderError: Error {
    case notChosen
    case unreachable
}

final class BookmarkedBackupFolder: BackupFolder {
    private static let bookmarkKey = "automaticBackupFolderBookmark"
    private static let nameKey = "automaticBackupFolderName"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var name: String? {
        guard userDefaults.data(forKey: BookmarkedBackupFolder.bookmarkKey) != nil else { return nil }
        return userDefaults.string(forKey: BookmarkedBackupFolder.nameKey)
    }

    func choose(_ url: URL) throws {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing { url.stopAccessingSecurityScopedResource() }
        }
        let bookmark = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        userDefaults.set(bookmark, forKey: BookmarkedBackupFolder.bookmarkKey)
        userDefaults.set(url.lastPathComponent, forKey: BookmarkedBackupFolder.nameKey)
    }

    func forget() {
        userDefaults.removeObject(forKey: BookmarkedBackupFolder.bookmarkKey)
        userDefaults.removeObject(forKey: BookmarkedBackupFolder.nameKey)
    }

    func write(_ file: BackupFile) throws {
        try accessFolder { folder in
            try coordinate(folder.appendingPathComponent(file.fileName), options: .forReplacing) { destination in
                try file.data.write(to: destination, options: .atomic)
            }
        }
    }

    func listFileNames() throws -> [String] {
        return try accessFolder { folder in
            try FileManager.default.contentsOfDirectory(atPath: folder.path)
        }
    }

    func deleteFile(named fileName: String) throws {
        try accessFolder { folder in
            try coordinate(folder.appendingPathComponent(fileName), options: .forDeleting) { target in
                try FileManager.default.removeItem(at: target)
            }
        }
    }

    private func accessFolder<Result>(_ body: (URL) throws -> Result) throws -> Result {
        guard let bookmark = userDefaults.data(forKey: BookmarkedBackupFolder.bookmarkKey) else { throw BackupFolderError.notChosen }
        var isStale = false
        let folder = try URL(resolvingBookmarkData: bookmark, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
        let isAccessing = folder.startAccessingSecurityScopedResource()
        defer {
            if isAccessing { folder.stopAccessingSecurityScopedResource() }
        }
        guard FileManager.default.fileExists(atPath: folder.path) else { throw BackupFolderError.unreachable }
        if isStale, let refreshedBookmark = try? folder.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
            userDefaults.set(refreshedBookmark, forKey: BookmarkedBackupFolder.bookmarkKey)
        }
        return try body(folder)
    }

    private func coordinate(_ url: URL, options: NSFileCoordinator.WritingOptions, _ body: (URL) throws -> Void) throws {
        var coordinationError: NSError?
        var bodyError: Error?
        NSFileCoordinator().coordinate(writingItemAt: url, options: options, error: &coordinationError) { coordinatedURL in
            do {
                try body(coordinatedURL)
            }
            catch {
                bodyError = error
            }
        }
        if let error = coordinationError ?? bodyError {
            throw error
        }
    }
}
