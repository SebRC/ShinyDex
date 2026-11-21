import Foundation

struct SetYearlyGoalCommand {
    let year: Int
    let target: Int?
}

final class SetYearlyGoalHandler {
    private let yearlyGoalRepository: YearlyGoalRepository

    init(yearlyGoalRepository: YearlyGoalRepository) {
        self.yearlyGoalRepository = yearlyGoalRepository
    }

    func handle(_ command: SetYearlyGoalCommand) {
        guard let target = command.target, target > 0 else {
            yearlyGoalRepository.delete(year: command.year)
            return
        }
        yearlyGoalRepository.save(YearlyGoal(year: command.year, target: target))
    }
}
