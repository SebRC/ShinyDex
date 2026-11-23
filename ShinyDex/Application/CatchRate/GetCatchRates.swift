import Foundation

struct GetCatchRatesQuery {
    let number: Int
    var formId: String? = nil
    let game: Games
    var situation = CatchSituation()
}

struct BallCatchRate: Equatable {
    let ball: String
    let chance: Double
    let chanceWithinFive: Double
    let chanceWithinTen: Double
    let bonus: BallBonus

    var expectedThrows: Double? {
        return chance > 0 ? 1 / chance : nil
    }
}

struct CatchRateSheet: Equatable {
    let number: Int
    let pokemonName: String
    let formId: String?
    let game: Games
    let catchRate: Int
    let types: [String]
    let maxHP: Int
    let currentHP: Int
    let rates: [BallCatchRate]
}

final class GetCatchRatesHandler {
    static let throwCountsShown = (few: 5, many: 10)

    private let pokemonRepository: PokemonRepository
    private let catchData: PokemonCatchData
    private let baseStats: PokemonBaseStats

    init(pokemonRepository: PokemonRepository, catchData: PokemonCatchData = PokemonCatchData(), baseStats: PokemonBaseStats = PokemonBaseStats()) {
        self.pokemonRepository = pokemonRepository
        self.catchData = catchData
        self.baseStats = baseStats
    }

    static var supportedGames: [Games] {
        return Games.allCases.filter(CatchRateCalculator.isSupported)
    }

    func handle(_ query: GetCatchRatesQuery) -> CatchRateSheet? {
        guard CatchRateCalculator.isSupported(query.game),
              let pokemon = pokemonRepository.get(number: query.number),
              let profile = catchData.findProfile(of: query.number, formId: query.formId) else { return nil }
        let base = baseStats.findStats(of: query.number, formId: query.formId)
        let target = CatchTarget(number: query.number, profile: profile, baseSpeed: base?[.speed])
        let situation = query.situation
        let maxHP = CatchRateCalculator.calculateMaxHP(of: query.number, base: base, level: situation.level)
        let currentHP = CatchRateCalculator.calculateCurrentHP(maxHP: maxHP, situation: situation)
        let rates = BallRules.findBalls(in: query.game).map { ball -> BallCatchRate in
            let bonus = BallRules.findBonus(for: ball, in: query.game, target: target, situation: situation)
            let chance = CatchRateCalculator.calculateChance(catchRate: profile.catchRate, maxHP: maxHP, currentHP: currentHP, bonus: bonus, status: situation.status,
                                                             level: situation.level, game: query.game)
            return BallCatchRate(ball: ball, chance: chance,
                                 chanceWithinFive: CatchRateCalculator.calculateChanceWithin(throws: GetCatchRatesHandler.throwCountsShown.few, chancePerThrow: chance),
                                 chanceWithinTen: CatchRateCalculator.calculateChanceWithin(throws: GetCatchRatesHandler.throwCountsShown.many, chancePerThrow: chance),
                                 bonus: bonus)
        }
        let ranked = rates.enumerated().sorted { $0.element.chance != $1.element.chance ? $0.element.chance > $1.element.chance : $0.offset < $1.offset }.map { $0.element }
        return CatchRateSheet(number: query.number, pokemonName: pokemon.name, formId: query.formId, game: query.game, catchRate: profile.catchRate, types: profile.types,
                              maxHP: maxHP, currentHP: currentHP, rates: ranked)
    }
}
