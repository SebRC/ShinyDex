import Foundation

struct CreateBingoBoardCommand {
    let name: String
    let size: BingoBoardSize
    let pokemonNumbers: [Int]
}

final class CreateBingoBoardHandler {
    private let bingoBoardRepository: BingoBoardRepository

    init(bingoBoardRepository: BingoBoardRepository) {
        self.bingoBoardRepository = bingoBoardRepository
    }

    @discardableResult
    func handle(_ command: CreateBingoBoardCommand) -> BingoBoardID {
        let priority = (bingoBoardRepository.getAll().map { $0.priority }.max() ?? -1) + 1
        let board = BingoBoard(name: command.name, priority: priority, size: command.size, numbers: command.pokemonNumbers)
        bingoBoardRepository.save(board)
        return BingoBoardID(rawValue: board.id)
    }
}
