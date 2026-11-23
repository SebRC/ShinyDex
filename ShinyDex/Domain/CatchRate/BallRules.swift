import Foundation

struct CatchTarget: Equatable {
    let number: Int
    let profile: CatchProfile
    let baseSpeed: Int?
}

enum BallCondition: Equatable {
    case guaranteed
    case type(String)
    case surfingOrFishing
    case fishing
    case lowLevel(Int)
    case caughtBefore
    case turnsPassed(Int)
    case nightOrCave
    case firstTurn
    case fastPokemon(baseSpeed: Int)
    case levelAdvantage
    case weight(kilograms: Double)
    case sameSpeciesOppositeGender
    case moonStoneLine
    case asleep
    case ultraBeast
    case notUltraBeast
}

struct BallBonus: Equatable {
    var multiplier = 1.0
    var catchRateChange = 0
    var alwaysCatches = false
    var condition: BallCondition? = nil
}

enum BallRules {
    static let ultraBeastNumbers: Set<Int> = [792, 793, 794, 795, 796, 797, 798, 802, 803, 804, 805]
    static let fastBaseSpeed = 100
    static let alwaysAvailableBalls = ["poke", "great", "ultra", "master"]
    static let hoennBalls = ["premier", "net", "dive", "nest", "repeat", "timer", "luxury"]
    static let sinnohBalls = ["dusk", "quick", "heal"]
    static let apricornBalls = ["fast", "level", "lure", "heavy", "love", "friend", "moon"]
    static let safariGames: Set<Games> = [.Ruby, .Sapphire, .Emerald, .FireRed, .LeafGreen, .Diamond, .Pearl, .Platinum, .Heartgold, .SoulSilver, .BrilliantDiamond, .ShiningPearl]
    static let apricornGames: Set<Games> = [.Heartgold, .SoulSilver, .Sun, .Moon, .UltraSun, .UltraMoon, .Sword, .Shield, .Scarlet, .Violet]
    static let dreamBallGames: Set<Games> = [.Sword, .Shield, .Scarlet, .Violet]
    static let beastBallGames: Set<Games> = [.Sun, .Moon, .UltraSun, .UltraMoon, .Sword, .Shield, .Scarlet, .Violet]
    static let sportBallGames: Set<Games> = [.Heartgold, .SoulSilver]

    static func findBalls(in game: Games) -> [String] {
        let generation = findGeneration(of: game)
        var balls = alwaysAvailableBalls + hoennBalls
        if (generation >= 4) {
            balls += sinnohBalls
        }
        if (safariGames.contains(game)) {
            balls.append("safari")
        }
        if (sportBallGames.contains(game)) {
            balls.append("sport")
        }
        if (apricornGames.contains(game)) {
            balls += apricornBalls
        }
        if (dreamBallGames.contains(game)) {
            balls.append("dream")
        }
        if (beastBallGames.contains(game)) {
            balls.append("beast")
        }
        return balls
    }

    static func findBonus(for ball: String, in game: Games, target: CatchTarget, situation: CatchSituation) -> BallBonus {
        let generation = findGeneration(of: game)
        let isHeartGoldSoulSilver = game == .Heartgold || game == .SoulSilver
        switch ball {
        case "master":
            return BallBonus(alwaysCatches: true, condition: .guaranteed)
        case "great", "safari", "sport":
            return BallBonus(multiplier: 1.5)
        case "ultra":
            return BallBonus(multiplier: 2)
        case "net":
            guard let type = target.profile.types.first(where: { $0 == "water" || $0 == "bug" }) else { return BallBonus() }
            return BallBonus(multiplier: generation >= 7 ? 3.5 : 3, condition: .type(type))
        case "dive":
            guard generation >= 4, situation.place == .surfing || situation.place == .fishing else { return BallBonus() }
            return BallBonus(multiplier: 3.5, condition: .surfingOrFishing)
        case "nest":
            return findNestBonus(level: situation.level, generation: generation)
        case "repeat":
            guard situation.isRegisteredAsCaught else { return BallBonus() }
            return BallBonus(multiplier: generation >= 7 ? 3.5 : 3, condition: .caughtBefore)
        case "timer":
            return findTimerBonus(turnsPassed: situation.turn - CatchSituation.firstTurn, generation: generation)
        case "dusk":
            guard situation.isNight || situation.place == .cave else { return BallBonus() }
            return BallBonus(multiplier: generation >= 7 ? 3 : 3.5, condition: .nightOrCave)
        case "quick":
            guard situation.turn == CatchSituation.firstTurn else { return BallBonus() }
            return BallBonus(multiplier: generation >= 5 ? 5 : 4, condition: .firstTurn)
        case "fast":
            guard let baseSpeed = target.baseSpeed, baseSpeed >= fastBaseSpeed else { return BallBonus() }
            return BallBonus(multiplier: 4, condition: .fastPokemon(baseSpeed: baseSpeed))
        case "level":
            return findLevelBonus(yourLevel: situation.yourLevel, wildLevel: situation.level)
        case "lure":
            guard situation.place == .fishing else { return BallBonus() }
            return BallBonus(multiplier: isHeartGoldSoulSilver ? 3 : (generation == 7 ? 5 : 4), condition: .fishing)
        case "heavy":
            return findHeavyBonus(kilograms: target.profile.weightInKilograms, isHeartGoldSoulSilver: isHeartGoldSoulSilver)
        case "love":
            guard situation.isSameSpeciesOppositeGender else { return BallBonus() }
            return BallBonus(multiplier: 8, condition: .sameSpeciesOppositeGender)
        case "moon":
            guard target.profile.isInMoonStoneLine else { return BallBonus() }
            return BallBonus(multiplier: 4, condition: .moonStoneLine)
        case "dream":
            guard situation.status == .sleep else { return BallBonus() }
            return BallBonus(multiplier: 4, condition: .asleep)
        case "beast":
            let isUltraBeast = ultraBeastNumbers.contains(target.number)
            return BallBonus(multiplier: isUltraBeast ? 5 : 0.1, condition: isUltraBeast ? .ultraBeast : .notUltraBeast)
        default:
            return BallBonus()
        }
    }

    static func findGeneration(of game: Games) -> Int {
        return GamesList.games[game]?.generation ?? 0
    }

    fileprivate static func findNestBonus(level: Int, generation: Int) -> BallBonus {
        let multiplier: Double
        if (generation >= 5) {
            multiplier = level < 30 ? Double(41 - level) / 10 : 1
        }
        else {
            multiplier = max(1, Double(40 - level) / 10)
        }
        return multiplier > 1 ? BallBonus(multiplier: multiplier, condition: .lowLevel(level)) : BallBonus()
    }

    fileprivate static func findTimerBonus(turnsPassed: Int, generation: Int) -> BallBonus {
        let multiplier = generation >= 5 ? min(4, 1 + Double(turnsPassed) * 1229 / 4096) : min(4, Double(turnsPassed + 10) / 10)
        return multiplier > 1 ? BallBonus(multiplier: multiplier, condition: .turnsPassed(turnsPassed)) : BallBonus()
    }

    fileprivate static func findLevelBonus(yourLevel: Int, wildLevel: Int) -> BallBonus {
        let multiplier: Double
        if (yourLevel > wildLevel * 4) {
            multiplier = 8
        }
        else if (yourLevel > wildLevel * 2) {
            multiplier = 4
        }
        else if (yourLevel > wildLevel) {
            multiplier = 2
        }
        else {
            multiplier = 1
        }
        return multiplier > 1 ? BallBonus(multiplier: multiplier, condition: .levelAdvantage) : BallBonus()
    }

    fileprivate static func findHeavyBonus(kilograms: Double, isHeartGoldSoulSilver: Bool) -> BallBonus {
        let change: Int
        if (isHeartGoldSoulSilver) {
            change = kilograms < 204.8 ? -20 : (kilograms < 307.2 ? 20 : (kilograms < 409.6 ? 30 : 40))
        }
        else {
            change = kilograms < 100 ? -20 : (kilograms < 200 ? 0 : (kilograms < 300 ? 20 : 30))
        }
        return BallBonus(catchRateChange: change, condition: .weight(kilograms: kilograms))
    }
}
