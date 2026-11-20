import Foundation

struct ShinyChanceCalculator {
    static let maximumEncounters = 10_000_000

    let odds: OddsService
    let probability: ProbabilityService

    func calculateChance(encounters: Int, chain: Int, configuration: HuntConfiguration) -> Double {
        let encounters = max(encounters, 0)
        guard configuration.usesChain else {
            return probability.getProbability(encounters: encounters, shinyOdds: odds.getShinyOdds(configuration: configuration, chain: 0))
        }
        let chainEncounters = min(max(chain, 0), encounters)
        let earlierEncounters = encounters - chainEncounters
        let chanceOfMissingEarlier = calculateChanceOfMissing(encounters: earlierEncounters, atOdds: odds.getShinyOdds(configuration: configuration, chain: 0))
        let chanceOfMissingChain = calculateChanceOfMissingChain(length: chainEncounters, configuration: configuration)
        return (1 - chanceOfMissingEarlier * chanceOfMissingChain) * 100
    }

    func calculateChanceOfUnbrokenChain(length: Int, configuration: HuntConfiguration) -> Double {
        return calculateChance(encounters: length, chain: length, configuration: configuration)
    }

    func findChainLengthNeeded(forChance targetPercent: Double, configuration: HuntConfiguration) -> Int? {
        guard calculateChanceOfUnbrokenChain(length: ShinyChanceCalculator.maximumEncounters, configuration: configuration) >= targetPercent else { return nil }
        var lowest = 0
        var highest = ShinyChanceCalculator.maximumEncounters
        while lowest < highest {
            let middle = (lowest + highest) / 2
            if calculateChanceOfUnbrokenChain(length: middle, configuration: configuration) >= targetPercent {
                highest = middle
            }
            else {
                lowest = middle + 1
            }
        }
        return lowest
    }

    fileprivate func calculateChanceOfMissingChain(length: Int, configuration: HuntConfiguration) -> Double {
        let stepsWithChangingOdds = min(length, configuration.chainForBestOdds)
        var chanceOfMissing = 1.0
        for step in 0..<stepsWithChangingOdds {
            chanceOfMissing *= 1 - 1 / Double(odds.getShinyOdds(configuration: configuration, chain: step))
        }
        let bestOdds = odds.getShinyOdds(configuration: configuration, chain: configuration.chainForBestOdds)
        return chanceOfMissing * calculateChanceOfMissing(encounters: length - stepsWithChangingOdds, atOdds: bestOdds)
    }

    fileprivate func calculateChanceOfMissing(encounters: Int, atOdds shinyOdds: Int) -> Double {
        return pow(1 - 1 / Double(shinyOdds), Double(encounters))
    }
}
