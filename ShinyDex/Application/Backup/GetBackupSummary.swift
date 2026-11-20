import Foundation

struct GetBackupSummaryQuery {
    let data: Data
}

final class GetBackupSummaryHandler {
    func handle(_ query: GetBackupSummaryQuery) throws -> BackupSummary {
        let document = try BackupDocument.decode(from: query.data)
        return BackupSummary(
            createdDate: document.createdDate,
            catchCount: document.catches.filter { !$0.isFailed }.count,
            huntCount: document.hunts.count,
            journeyCount: document.journeys.count,
            bingoBoardCount: document.bingoBoards.count)
    }
}
