import Foundation

enum StatCalculator {
    static let shedinjaNumber = 291
    static let levelRange = Catch.levelRange
    fileprivate static let effortValuesPerStatPoint = 4
    fileprivate static let raisedNaturePercent = 110
    fileprivate static let loweredNaturePercent = 90

    static func calculateStats(of number: Int, base: BaseStats, ivs: IndividualValues, evs: EffortValues, nature: Nature?, level: BattleLevel) -> [Int?] {
        return calculateStats(of: number, base: base, ivs: ivs, evs: evs, nature: nature, level: level.rawValue)
    }

    static func calculateStats(of number: Int, base: BaseStats, ivs: IndividualValues, evs: EffortValues, nature: Nature?, level: Int) -> [Int?] {
        let clampedLevel = clampLevel(level)
        return Stat.allCases.map { stat in
            ivs[stat].map { iv in
                calculate(stat, of: number, base: base[stat], iv: iv, ev: evs[stat], nature: nature, level: clampedLevel)
            }
        }
    }

    static func clampLevel(_ level: Int) -> Int {
        return Catch.normalizeLevel(level) ?? level
    }

    static func calculate(_ stat: Stat, of number: Int, base: Int, iv: Int, ev: Int, nature: Nature?, level: Int) -> Int {
        let scaled = (2 * base + iv + ev / effortValuesPerStatPoint) * level / 100
        guard stat != .hp else {
            return number == shedinjaNumber ? 1 : scaled + level + 10
        }
        return (scaled + 5) * findNaturePercent(for: stat, nature: nature) / 100
    }

    fileprivate static func findNaturePercent(for stat: Stat, nature: Nature?) -> Int {
        switch stat {
        case nature?.raisedStat: return raisedNaturePercent
        case nature?.loweredStat: return loweredNaturePercent
        default: return 100
        }
    }
}
