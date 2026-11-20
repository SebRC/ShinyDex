import Foundation

struct UpdateBingoBoardCommand {
    enum Change: Equatable {
        case rename(String)
        case place(number: Int, at: Int)
        case clear(at: Int)
        case link(at: Int, catchId: CatchID?)
        case swap(Int, Int)
        case fillEmptyCells([Int])
        case shuffle
        case setForm(at: Int, formId: String?)
    }

    let boardId: BingoBoardID
    let change: Change
}

final class UpdateBingoBoardHandler {
    private let bingoBoardRepository: BingoBoardRepository
    private var generator: RandomNumberGenerator

    init(bingoBoardRepository: BingoBoardRepository, generator: RandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.bingoBoardRepository = bingoBoardRepository
        self.generator = generator
    }

    func handle(_ command: UpdateBingoBoardCommand) {
        guard let board = bingoBoardRepository.find(command.boardId) else { return }
        switch command.change {
        case .rename(let name):
            board.name = name
        case .place(let number, let index):
            board.place(number, at: index)
        case .clear(let index):
            board.clear(at: index)
        case .link(let index, let catchId):
            guard board.link(catchId?.rawValue, at: index) else { return }
        case .swap(let first, let second):
            board.swap(first, second)
        case .fillEmptyCells(let numbers):
            board.fillEmptyCells(with: numbers)
        case .shuffle:
            board.shuffle(using: &generator)
        case .setForm(let index, let formId):
            board.setForm(formId, at: index)
        }
        bingoBoardRepository.save(board)
    }
}
