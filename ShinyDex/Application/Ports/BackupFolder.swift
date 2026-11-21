import Foundation

protocol BackupFolder {
    var name: String? { get }
    func choose(_ url: URL) throws
    func forget()
    func write(_ file: BackupFile) throws
    func listFileNames() throws -> [String]
    func deleteFile(named fileName: String) throws
}
