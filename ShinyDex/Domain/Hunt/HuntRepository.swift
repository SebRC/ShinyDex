import Foundation

protocol HuntRepository {
    func getAll() -> [Hunt]
    func save(_ hunt: Hunt)
    func delete(_ hunt: Hunt)
    func clear()
}
