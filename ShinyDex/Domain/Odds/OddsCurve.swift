import Foundation

struct OddsCurve {
    struct Point: Equatable {
        let encounters: Int
        let chance: Double
    }

    struct Milestone: Equatable {
        let chance: Double
        let encounters: Int
    }

    static let milestoneChances = [50.0, 90.0, 99.0]
    static let sampleCount = 80
    static let headroom = 1.15

    let current: Point
    let milestones: [Milestone]
    let points: [Point]

    init(encounters: Int, chain: Int, configuration: HuntConfiguration, calculator: ShinyChanceCalculator) {
        let calculateChance = { (total: Int) -> Double in
            let chainAtTotal = configuration.usesChain ? min(max(chain + total - encounters, 0), total) : 0
            return calculator.calculateChance(encounters: total, chain: chainAtTotal, configuration: configuration)
        }
        current = Point(encounters: max(encounters, 0), chance: calculateChance(max(encounters, 0)))
        milestones = OddsCurve.milestoneChances.compactMap { target in
            OddsCurve.findEncounters(reaching: target, calculateChance: calculateChance).map { Milestone(chance: target, encounters: $0) }
        }
        let lastMilestone = milestones.last?.encounters ?? current.encounters * 2
        let end = max(Int(Double(max(current.encounters, lastMilestone)) * OddsCurve.headroom), OddsCurve.sampleCount)
        points = (0...OddsCurve.sampleCount).map { step in
            let total = end * step / OddsCurve.sampleCount
            return Point(encounters: total, chance: calculateChance(total))
        }
    }

    var lastEncounters: Int {
        return points.last?.encounters ?? 0
    }

    fileprivate static func findEncounters(reaching target: Double, calculateChance: (Int) -> Double) -> Int? {
        guard calculateChance(ShinyChanceCalculator.maximumEncounters) >= target else { return nil }
        var lowest = 0
        var highest = ShinyChanceCalculator.maximumEncounters
        while lowest < highest {
            let middle = (lowest + highest) / 2
            if (calculateChance(middle) >= target) {
                highest = middle
            }
            else {
                lowest = middle + 1
            }
        }
        return lowest
    }
}
