import Foundation

protocol YearlyGoalRepository {
    func getAll() -> [YearlyGoal]
    func save(_ goal: YearlyGoal)
    func delete(year: Int)
}
