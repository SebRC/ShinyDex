import Foundation

struct AchievementFacts {
    let catches: [Catch]
    var encountersInProgress = 0
    var ballNames = [String]()
    var forms = PokemonForms()
    var evolutions = Evolutions(evolvesFrom: [])
    var moveCategories = MoveCategories()
    var largestHuntSize = 0
    var longestHuntingDayStreak = 0
    var yearlyGoals = [YearlyGoal]()
    var completedJourneyCount = 0
    var completedBingoLineCount = 0
    var blackoutBoardCount = 0
    var hasAutomaticBackups = false
    var calendar = Calendar.current
}
