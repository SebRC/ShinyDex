import Foundation

enum EncounterMilestone: Equatable {
    case oddsMultiple(Int)
    case encounters(Int)

    static let encounterStep = 1000

    static func findCrossed(from previousEncounters: Int, to encounters: Int, shinyOdds: Int, countsTowardsOdds: Bool) -> EncounterMilestone? {
        guard encounters > previousEncounters else { return nil }
        if countsTowardsOdds, shinyOdds > 0, encounters / shinyOdds > previousEncounters / shinyOdds {
            return .oddsMultiple(encounters / shinyOdds)
        }
        if encounters / encounterStep > previousEncounters / encounterStep {
            return .encounters(encounters / encounterStep * encounterStep)
        }
        return nil
    }
}
