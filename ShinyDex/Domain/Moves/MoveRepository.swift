import Foundation

protocol MoveRepository {
    func getActiveMoves() -> ActiveMoves?
    func insert(_ activeMoves: ActiveMoves)
    func save(_ activeMoves: ActiveMoves)
}
