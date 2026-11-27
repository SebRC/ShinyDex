import Foundation

struct StatLeaderboard {
    struct Entry {
        let caught: Catch
        let iv: Int
        let value: Int
        let trainedValue: Int?
        var trainedRank: Int? = nil
    }

    let entries: [Entry]
    let catchesWithoutIV: Int

    init(catches: [Catch], stat: Stat, level: BattleLevel, baseStats: PokemonBaseStats) {
        var withoutIV = 0
        let unranked = catches.compactMap { caught -> Entry? in
            guard let iv = caught.ivs[stat] else {
                withoutIV += 1
                return nil
            }
            guard let base = baseStats.findStats(of: caught.number, formId: caught.formId) else { return nil }
            let value = StatCalculator.calculate(stat, of: caught.number, base: base[stat], iv: iv, ev: caught.evs[stat], nature: caught.nature, level: level.rawValue)
            let trainedEV = StatLeaderboard.findTrainedEV(of: caught.evs, in: stat)
            let trainedValue = StatCalculator.calculate(stat, of: caught.number, base: base[stat], iv: iv, ev: trainedEV, nature: caught.nature, level: level.rawValue)
            return Entry(caught: caught, iv: iv, value: value, trainedValue: trainedValue > value ? trainedValue : nil)
        }
        let ranked = unranked.sorted { ($0.value, $0.iv, -$0.caught.number) > ($1.value, $1.iv, -$1.caught.number) }
        entries = ranked.enumerated().map { index, entry in
            guard let trainedValue = entry.trainedValue else { return entry }
            let trainedRank = 1 + ranked.enumerated().filter { $0.offset != index && $0.element.value > trainedValue }.count
            var withRank = entry
            withRank.trainedRank = trainedRank < index + 1 ? trainedRank : nil
            return withRank
        }
        catchesWithoutIV = withoutIV
    }

    static func findTrainedEV(of evs: EffortValues, in stat: Stat) -> Int {
        return min(EffortValues.maximumUsefulPerStat, evs[stat] + evs.remaining)
    }
}
