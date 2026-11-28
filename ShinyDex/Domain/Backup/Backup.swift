import Foundation

struct Backup {
    let pokemon: [Pokemon]
    let catches: [Catch]
    let hunts: [Hunt]
    let journeys: [Journey]
    let bingoBoards: [BingoBoard]
    let activeMoves: ActiveMoves?
    var encounterLedger: EncounterLedger? = nil
    var yearlyGoals: [YearlyGoal]? = nil
    var dailyEncounters: [DailyEncounters]? = nil
    var teams: [Team]? = nil
}
