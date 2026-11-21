import Foundation

enum MilestoneText {
    static func makeMessage(for milestone: ReachedMilestone) -> String {
        switch milestone.kind {
        case .oddsMultiple(1):
            return "\(milestone.pokemonName) has reached its odds. A shiny could be next!"
        case .oddsMultiple(let multiple):
            return "\(milestone.pokemonName) is at \(multiple)× its odds. Keep going!"
        case .encounters(let encounters):
            return "\(milestone.pokemonName) hit \(encounters.grouped) encounters!"
        }
    }

    static func makeShortLabel(for milestone: ReachedMilestone) -> String {
        switch milestone.kind {
        case .oddsMultiple(1): return "At odds"
        case .oddsMultiple(let multiple): return "\(multiple)× odds"
        case .encounters(let encounters): return "\(encounters.grouped) encounters"
        }
    }
}
