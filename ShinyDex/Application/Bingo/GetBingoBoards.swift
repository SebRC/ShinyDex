import Foundation

struct GetBingoBoardsQuery {}

final class GetBingoBoardsHandler {
    private let bingoBoardRepository: BingoBoardRepository
    private let catchRepository: CatchRepository

    init(bingoBoardRepository: BingoBoardRepository, catchRepository: CatchRepository) {
        self.bingoBoardRepository = bingoBoardRepository
        self.catchRepository = catchRepository
    }

    func handle(_ query: GetBingoBoardsQuery) -> [BingoBoardSummary] {
        let catchesById = Dictionary(catchRepository.getAll().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return bingoBoardRepository.getAll()
            .sorted { $0.priority < $1.priority }
            .map { board in
                BingoBoardSummary(
                    id: BingoBoardID(rawValue: board.id),
                    name: board.name,
                    size: board.size,
                    filledCount: board.filledCount,
                    obtainedCount: board.countObtained(in: catchesById),
                    completedLineCount: board.findCompletedLines(in: catchesById).count)
            }
    }
}
