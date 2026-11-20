import Foundation

struct SimulateOddsQuery {
    let settings: HuntSettings
    let encounters: Int
    var selectingGame: Games? = nil
}

struct ChanceMilestone: Equatable {
    let percent: Int
    let encounters: Int?
}

struct OddsSimulation: Equatable {
    let settings: HuntSettings
    let encounters: Int
    let shinyOdds: Int
    let chance: Double
    let usesChain: Bool
    let milestones: [ChanceMilestone]
}

final class SimulateOddsHandler {
    static let milestonePercents = [50, 90, 99]

    private let odds: OddsService
    private let calculator: ShinyChanceCalculator

    init(odds: OddsService, probability: ProbabilityService) {
        self.odds = odds
        calculator = ShinyChanceCalculator(odds: odds, probability: probability)
    }

    func handle(_ query: SimulateOddsQuery) -> OddsSimulation {
        var configuration = query.settings.configuration
        if let game = query.selectingGame {
            configuration = configuration.selecting(game)
        }
        configuration = configuration.normalized()
        let encounters = min(max(query.encounters, 0), ShinyChanceCalculator.maximumEncounters)
        return OddsSimulation(
            settings: HuntSettings(configuration),
            encounters: encounters,
            shinyOdds: odds.getShinyOdds(configuration: configuration, chain: encounters),
            chance: calculator.calculateChanceOfUnbrokenChain(length: encounters, configuration: configuration),
            usesChain: configuration.usesChain,
            milestones: SimulateOddsHandler.milestonePercents.map {
                ChanceMilestone(percent: $0, encounters: calculator.findChainLengthNeeded(forChance: Double($0), configuration: configuration))
            })
    }
}
