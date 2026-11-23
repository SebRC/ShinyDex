import Foundation

struct JourneyTally: Equatable {
    let encounters: Int
    let shinyCount: Int
    let expectedShinies: Double?
    let catchesWithUnknownOdds: Int

    init(catches: [Catch]) {
        encounters = catches.reduce(0) { $0 + $1.encounters }
        shinyCount = catches.count
        let oddsByCatch = catches.compactMap { caught in CatchOdds.getOdds(for: caught).map { (caught, $0) } }
        expectedShinies = oddsByCatch.isEmpty ? nil : oddsByCatch.reduce(0) { $0 + Double($1.0.encounters) / Double($1.1) }
        catchesWithUnknownOdds = catches.count - oddsByCatch.count
    }
}
