import Foundation

protocol TeamRepository {
    func getAll() -> [Team]
    func save(_ team: Team)
    func delete(id: UUID)
}
