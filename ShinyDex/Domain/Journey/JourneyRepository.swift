import Foundation

protocol JourneyRepository {
    func getAll() -> [Journey]
    @discardableResult
    func save(_ journey: Journey) -> Bool
    func delete(_ journey: Journey)
}
