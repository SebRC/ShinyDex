import Foundation

struct DeleteBingoBoardCommand {
    let boardId: BingoBoardID
}

final class DeleteBingoBoardHandler {
    private let bingoBoardRepository: BingoBoardRepository

    init(bingoBoardRepository: BingoBoardRepository) {
        self.bingoBoardRepository = bingoBoardRepository
    }

    func handle(_ command: DeleteBingoBoardCommand) {
        guard let board = bingoBoardRepository.find(command.boardId) else { return }
        bingoBoardRepository.delete(board)
    }
}
