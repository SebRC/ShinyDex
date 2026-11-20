import Foundation

protocol BingoBoardRepository {
    func getAll() -> [BingoBoard]
    @discardableResult
    func save(_ board: BingoBoard) -> Bool
    func delete(_ board: BingoBoard)
}
