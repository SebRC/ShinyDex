import Foundation

protocol CatchRepository {
    func getAll() -> [Catch]
    func getAll(number: Int) -> [Catch]
    func get(id: UUID) -> Catch?
    func insert(_ caught: Catch)
    func update(_ caught: Catch)
    func delete(_ caught: Catch)
    @discardableResult
    func save() -> Bool
}
