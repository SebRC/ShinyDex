import Foundation

struct BackupFile: Equatable {
    let fileName: String
    let data: Data
}

struct BackupSummary: Equatable {
    let createdDate: Date
    let catchCount: Int
    let huntCount: Int
    let journeyCount: Int
    let bingoBoardCount: Int
}
