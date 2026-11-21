import Foundation

struct YearlyGoalProgress: Equatable {
    let goal: YearlyGoal
    let foundCount: Int
    let expectedByNow: Int

    var isReached: Bool {
        return foundCount >= goal.target
    }

    var aheadOfPace: Int {
        return foundCount - expectedByNow
    }

    init(goal: YearlyGoal, catches: [Catch], now: Date, calendar: Calendar) {
        self.goal = goal
        foundCount = catches.filter { caught in
            caught.caughtDate.map { calendar.component(.year, from: $0) == goal.year } ?? false
        }.count
        let elapsedFraction = YearlyGoalProgress.calculateElapsedFraction(of: goal.year, at: now, calendar: calendar)
        expectedByNow = Int((Double(goal.target) * elapsedFraction).rounded())
    }

    private static func calculateElapsedFraction(of year: Int, at now: Date, calendar: Calendar) -> Double {
        guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) else { return 0 }
        let fraction = now.timeIntervalSince(start) / end.timeIntervalSince(start)
        return min(max(fraction, 0), 1)
    }
}
