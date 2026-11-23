import Foundation

enum CatchRateCalculator {
    static let firstSupportedGeneration = 3
    static let unsupportedGames: Set<Games> = [.LetsGoPikachu, .LetsGoEevee, .LegendsArceus]
    static let assumedIV = 15
    static let fallbackMaxHP = 100
    static let maximumCatchValue = 255.0

    static func isSupported(_ game: Games) -> Bool {
        return BallRules.findGeneration(of: game) >= firstSupportedGeneration && !unsupportedGames.contains(game)
    }

    static func calculateMaxHP(of number: Int, base: BaseStats?, level: Int) -> Int {
        guard let base = base else { return fallbackMaxHP }
        return StatCalculator.calculate(.hp, of: number, base: base[.hp], iv: assumedIV, ev: 0, nature: nil, level: StatCalculator.clampLevel(level))
    }

    static func calculateCurrentHP(maxHP: Int, situation: CatchSituation) -> Int {
        guard !situation.isAtOneHP else { return 1 }
        let percent = min(max(situation.hpPercent, CatchSituation.hpPercentRange.lowerBound), CatchSituation.hpPercentRange.upperBound)
        return max(1, Int((Double(maxHP) * Double(percent) / 100).rounded()))
    }

    static func calculateChance(catchRate: Int, maxHP: Int, currentHP: Int, bonus: BallBonus, status: CatchStatus, level: Int, game: Games) -> Double {
        guard !bonus.alwaysCatches else { return 1 }
        let generation = BallRules.findGeneration(of: game)
        let rate = max(1, catchRate + bonus.catchRateChange)
        let hpFactor = 3 * maxHP - 2 * min(currentHP, maxHP)
        if (generation <= 4) {
            return calculateClassicChance(rate: rate, hpFactor: hpFactor, maxHP: maxHP, ballMultiplier: bonus.multiplier, statusBonus: status.findBonus(inGeneration: generation))
        }
        let catchValue = Double(hpFactor) * Double(rate) * bonus.multiplier / Double(3 * maxHP) * status.findBonus(inGeneration: generation) * findLowLevelBonus(level: level, generation: generation)
        guard catchValue < maximumCatchValue else { return 1 }
        let shakeChecks = generation == 5 ? 3.0 : 4.0
        return pow(catchValue / maximumCatchValue, shakeChecks / 4)
    }

    fileprivate static func calculateClassicChance(rate: Int, hpFactor: Int, maxHP: Int, ballMultiplier: Double, statusBonus: Double) -> Double {
        let scaledRate = (Double(hpFactor * rate) * ballMultiplier).rounded(.down)
        let catchValue = max(1, ((scaledRate / Double(3 * maxHP)).rounded(.down) * statusBonus).rounded(.down))
        guard catchValue < maximumCatchValue else { return 1 }
        let shakeThreshold = (1_048_560 / (16_711_680 / catchValue).rounded(.down).squareRoot().rounded(.down).squareRoot().rounded(.down)).rounded(.down)
        return pow(min(shakeThreshold, 65_536) / 65_536, 4)
    }

    fileprivate static func findLowLevelBonus(level: Int, generation: Int) -> Double {
        switch generation {
        case 8 where level < 20: return Double(30 - level) / 10
        case 9 where level < 13: return Double(36 - 2 * level) / 10
        default: return 1
        }
    }

    static func calculateChanceWithin(throws throwCount: Int, chancePerThrow: Double) -> Double {
        return 1 - pow(1 - chancePerThrow, Double(throwCount))
    }
}
