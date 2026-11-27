import Foundation

struct CombinedStats: Equatable {
    static let assumedIV = 15

    let total: Int
    let isEstimated: Bool

    init(of number: Int, base: BaseStats, ivs: IndividualValues, evs: EffortValues, nature: Nature?, level: BattleLevel, style: AttackingStyle, countsUnusedStatFully: Bool) {
        let filledIVs = Stat.allCases.reduce(ivs) { filled, stat in
            filled[stat] == nil ? filled.setting(CombinedStats.assumedIV, for: stat) : filled
        }
        let values = StatCalculator.calculateStats(of: number, base: base, ivs: filledIVs, evs: evs, nature: nature, level: level)
        let weightedTotal = Stat.allCases.reduce(0.0) { sum, stat in
            let weight = stat == style.lessRelevantStat && !countsUnusedStatFully ? BattlerAssessment.lessRelevantWeight : 1
            return sum + Double(values[stat.rawValue] ?? 0) * weight
        }
        total = Int(weightedTotal.rounded())
        isEstimated = ivs.values.contains(nil)
    }
}
