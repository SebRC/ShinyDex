import Foundation

struct ShinyChanceCalculator {
    static let maximumEncounters = 10_000_000

    let odds: OddsService
    let probability: ProbabilityService

    func calculateChance(within encounters: Int, configuration: HuntConfiguration) -> Double {
        let shinyOdds = odds.getShinyOdds(configuration: configuration, encounters: encounters)
        let encountersAtBoostedOdds = max(encounters - configuration.chainThreshold, 0)
        return probability.getProbability(encounters: encountersAtBoostedOdds, shinyOdds: shinyOdds)
    }

    func findEncountersNeeded(forChance targetPercent: Double, configuration: HuntConfiguration) -> Int? {
        guard calculateChance(within: ShinyChanceCalculator.maximumEncounters, configuration: configuration) >= targetPercent else { return nil }
        var lowest = 0
        var highest = ShinyChanceCalculator.maximumEncounters
        while lowest < highest {
            let middle = (lowest + highest) / 2
            if calculateChance(within: middle, configuration: configuration) >= targetPercent {
                highest = middle
            }
            else {
                lowest = middle + 1
            }
        }
        return lowest
    }
}
