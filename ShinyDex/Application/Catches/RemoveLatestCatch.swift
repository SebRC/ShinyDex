import Foundation

struct RemoveLatestCatchCommand {
    let number: Int
}

final class RemoveLatestCatchHandler {
    private let catchRepository: CatchRepository
    private let deleteCatch: DeleteCatchHandler

    init(catchRepository: CatchRepository, deleteCatch: DeleteCatchHandler) {
        self.catchRepository = catchRepository
        self.deleteCatch = deleteCatch
    }

    @discardableResult
    func handle(_ command: RemoveLatestCatchCommand) -> Bool {
        let catches = CatchRules.sortedOldestFirst(catchRepository.getAll(number: command.number)).filter { !$0.isFailed }
        guard let latest = catches.last else { return false }
        deleteCatch.handle(DeleteCatchCommand(catchId: CatchID(rawValue: latest.id)))
        return true
    }
}
