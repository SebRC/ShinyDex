import XCTest
@testable import ShinyDex

final class CatchRateTests: XCTestCase {
    private let plain = CatchProfile(catchRate: 45, types: ["normal"], weightInHectograms: 100)

    private func makeTarget(number: Int = 0, profile: CatchProfile? = nil, baseSpeed: Int? = 50) -> CatchTarget {
        return CatchTarget(number: number, profile: profile ?? plain, baseSpeed: baseSpeed)
    }

    private func findMultiplier(_ ball: String, in game: Games, target: CatchTarget? = nil, situation: CatchSituation = CatchSituation()) -> Double {
        return BallRules.findBonus(for: ball, in: game, target: target ?? makeTarget(), situation: situation).multiplier
    }

    // MARK: Formula

    func test_fullHPPokeBall_matchesEachGenerationsFormula() {
        let bonus = BallBonus()

        XCTAssertEqual(CatchRateCalculator.calculateChance(catchRate: 255, maxHP: 100, currentHP: 100, bonus: bonus, status: .none, level: 50, game: .Emerald), 0.3369, accuracy: 0.0005)
        XCTAssertEqual(CatchRateCalculator.calculateChance(catchRate: 255, maxHP: 100, currentHP: 100, bonus: bonus, status: .none, level: 50, game: .Black), pow(85.0 / 255, 0.75), accuracy: 0.0005)
        XCTAssertEqual(CatchRateCalculator.calculateChance(catchRate: 255, maxHP: 100, currentHP: 100, bonus: bonus, status: .none, level: 50, game: .X), 85.0 / 255, accuracy: 0.0005)
    }

    func test_lowerHPAndStatus_raiseTheChance_andMasterBallAlwaysCatches() {
        func chance(hp: Int, status: CatchStatus) -> Double {
            return CatchRateCalculator.calculateChance(catchRate: 3, maxHP: 200, currentHP: hp, bonus: BallBonus(multiplier: 2), status: status, level: 70, game: .Scarlet)
        }

        XCTAssertLessThan(chance(hp: 200, status: .none), chance(hp: 1, status: .none))
        XCTAssertLessThan(chance(hp: 1, status: .paralysis), chance(hp: 1, status: .sleep))
        XCTAssertEqual(chance(hp: 1, status: .sleep), 3 * 2 * 2.5 * (600.0 - 2) / 600 / 255, accuracy: 0.0001)
        XCTAssertEqual(CatchRateCalculator.calculateChance(catchRate: 3, maxHP: 200, currentHP: 200, bonus: BallBonus(alwaysCatches: true), status: .none, level: 70, game: .Ruby), 1)
    }

    func test_sleepIsWorthMoreFromGenerationFive() {
        XCTAssertEqual(CatchStatus.sleep.findBonus(inGeneration: 4), 2)
        XCTAssertEqual(CatchStatus.sleep.findBonus(inGeneration: 5), 2.5)
        XCTAssertEqual(CatchStatus.burn.findBonus(inGeneration: 9), 1.5)
    }

    func test_lowLevelPokemon_areEasierToCatchInGenerationsEightAndNine() {
        let atLevelFive = CatchRateCalculator.calculateChance(catchRate: 45, maxHP: 100, currentHP: 100, bonus: BallBonus(), status: .none, level: 5, game: .Sword)
        let atLevelFifty = CatchRateCalculator.calculateChance(catchRate: 45, maxHP: 100, currentHP: 100, bonus: BallBonus(), status: .none, level: 50, game: .Sword)

        XCTAssertEqual(atLevelFive, atLevelFifty * 2.5, accuracy: 0.0001)
    }

    func test_hpFollowsThePercentOrOneHP() {
        let maxHP = CatchRateCalculator.calculateMaxHP(of: 0, base: BaseStats([45, 49, 49, 65, 65, 45]), level: 50)

        XCTAssertEqual(maxHP, 112)
        XCTAssertEqual(CatchRateCalculator.calculateCurrentHP(maxHP: maxHP, situation: CatchSituation(hpPercent: 50)), 56)
        XCTAssertEqual(CatchRateCalculator.calculateCurrentHP(maxHP: maxHP, situation: CatchSituation(hpPercent: 50, isAtOneHP: true)), 1)
        XCTAssertEqual(CatchRateCalculator.calculateChanceWithin(throws: 2, chancePerThrow: 0.5), 0.75)
    }

    func test_onlyGenerationThreeOnward_withoutLetsGoOrLegendsArceus_areSupported() {
        XCTAssertFalse(CatchRateCalculator.isSupported(.Crystal))
        XCTAssertFalse(CatchRateCalculator.isSupported(.LetsGoEevee))
        XCTAssertFalse(CatchRateCalculator.isSupported(.LegendsArceus))
        XCTAssertTrue(CatchRateCalculator.isSupported(.Ruby))
        XCTAssertTrue(CatchRateCalculator.isSupported(.Violet))
    }

    // MARK: Balls

    func test_ballsDependOnTheGame() {
        XCTAssertFalse(BallRules.findBalls(in: .Emerald).contains("dusk"))
        XCTAssertTrue(BallRules.findBalls(in: .Emerald).contains("safari"))
        XCTAssertFalse(BallRules.findBalls(in: .Platinum).contains("moon"))
        XCTAssertTrue(BallRules.findBalls(in: .Heartgold).contains("sport"))
        XCTAssertTrue(BallRules.findBalls(in: .Heartgold).contains("love"))
        XCTAssertTrue(BallRules.findBalls(in: .Scarlet).contains("dream"))
        XCTAssertTrue(BallRules.findBalls(in: .Scarlet).contains("beast"))
        XCTAssertFalse(BallRules.findBalls(in: .BrilliantDiamond).contains("level"))
    }

    func test_conditionalBalls_followTheSituationAndGeneration() {
        let water = makeTarget(profile: CatchProfile(catchRate: 45, types: ["water"], weightInHectograms: 100))
        XCTAssertEqual(findMultiplier("net", in: .X, target: water), 3)
        XCTAssertEqual(findMultiplier("net", in: .Sun, target: water), 3.5)
        XCTAssertEqual(findMultiplier("net", in: .Sun), 1)

        XCTAssertEqual(findMultiplier("quick", in: .Platinum), 4)
        XCTAssertEqual(findMultiplier("quick", in: .Scarlet), 5)
        XCTAssertEqual(findMultiplier("quick", in: .Scarlet, situation: CatchSituation(turn: 2)), 1)

        XCTAssertEqual(findMultiplier("timer", in: .Emerald, situation: CatchSituation(turn: 11)), 2)
        XCTAssertEqual(findMultiplier("timer", in: .Scarlet, situation: CatchSituation(turn: 11)), 4)

        XCTAssertEqual(findMultiplier("dusk", in: .Platinum, situation: CatchSituation(isNight: true)), 3.5)
        XCTAssertEqual(findMultiplier("dusk", in: .Scarlet, situation: CatchSituation(place: .cave)), 3)
        XCTAssertEqual(findMultiplier("dusk", in: .Scarlet), 1)

        XCTAssertEqual(findMultiplier("nest", in: .Emerald, situation: CatchSituation(level: 10)), 3)
        XCTAssertEqual(findMultiplier("nest", in: .Scarlet, situation: CatchSituation(level: 10)), 3.1, accuracy: 0.0001)
        XCTAssertEqual(findMultiplier("nest", in: .Scarlet, situation: CatchSituation(level: 40)), 1)

        XCTAssertEqual(findMultiplier("dive", in: .Scarlet, situation: CatchSituation(place: .surfing)), 3.5)
        XCTAssertEqual(findMultiplier("lure", in: .Heartgold, situation: CatchSituation(place: .fishing)), 3)
        XCTAssertEqual(findMultiplier("lure", in: .Sword, situation: CatchSituation(place: .fishing)), 4)
    }

    func test_ballsThatDependOnThePokemon() {
        XCTAssertEqual(findMultiplier("repeat", in: .Scarlet, situation: CatchSituation(isRegisteredAsCaught: true)), 3.5)
        XCTAssertEqual(findMultiplier("repeat", in: .X, situation: CatchSituation(isRegisteredAsCaught: true)), 3)
        XCTAssertEqual(findMultiplier("repeat", in: .Scarlet), 1)
        XCTAssertEqual(findMultiplier("fast", in: .Scarlet, target: makeTarget(baseSpeed: 100)), 4)
        XCTAssertEqual(findMultiplier("fast", in: .Scarlet, target: makeTarget(baseSpeed: 99)), 1)

        let moonStone = makeTarget(profile: CatchProfile(catchRate: 150, types: ["fairy"], weightInHectograms: 75, isInMoonStoneLine: true))
        XCTAssertEqual(findMultiplier("moon", in: .Scarlet, target: moonStone), 4)
        XCTAssertEqual(findMultiplier("moon", in: .Heartgold, target: moonStone), 4)
        XCTAssertEqual(findMultiplier("moon", in: .Heartgold), 1)

        XCTAssertEqual(findMultiplier("beast", in: .Sun, target: makeTarget(number: 792)), 5)
        XCTAssertEqual(findMultiplier("beast", in: .Sun), 0.1)
        XCTAssertEqual(findMultiplier("love", in: .Scarlet, situation: CatchSituation(isSameSpeciesOppositeGender: true)), 8)
        XCTAssertEqual(findMultiplier("dream", in: .Scarlet, situation: CatchSituation(status: .sleep)), 4)
        XCTAssertEqual(findMultiplier("level", in: .Scarlet, situation: CatchSituation(level: 10, yourLevel: 50)), 8)
        XCTAssertEqual(findMultiplier("level", in: .Scarlet, situation: CatchSituation(level: 20, yourLevel: 50)), 4)
    }

    func test_heavyBallChangesTheCatchRateByWeight() {
        let snorlax = makeTarget(profile: CatchProfile(catchRate: 25, types: ["normal"], weightInHectograms: 4600))
        let pidgey = makeTarget(profile: CatchProfile(catchRate: 255, types: ["normal", "flying"], weightInHectograms: 18))

        XCTAssertEqual(BallRules.findBonus(for: "heavy", in: .Heartgold, target: snorlax, situation: CatchSituation()).catchRateChange, 40)
        XCTAssertEqual(BallRules.findBonus(for: "heavy", in: .Scarlet, target: snorlax, situation: CatchSituation()).catchRateChange, 30)
        XCTAssertEqual(BallRules.findBonus(for: "heavy", in: .Scarlet, target: pidgey, situation: CatchSituation()).catchRateChange, -20)
    }

    // MARK: Handler

    private func makeHandler() -> GetCatchRatesHandler {
        let data = PokemonCatchData(profilesByNumber: [
            0: SpeciesCatchProfiles(standard: CatchProfile(catchRate: 45, types: ["water"], weightInHectograms: 100), profilesByFormId: [:])
        ])
        return GetCatchRatesHandler(pokemonRepository: InMemoryPokemonRepository(names: ["Squirtle"]), catchData: data,
                                    baseStats: PokemonBaseStats(statsByNumber: [0: SpeciesBaseStats(standard: BaseStats([44, 48, 65, 50, 64, 43]), statsByFormId: [:])]))
    }

    func test_ratesAreRankedBestFirst() {
        let sheet = makeHandler().handle(GetCatchRatesQuery(number: 0, game: .Scarlet))!

        XCTAssertEqual(sheet.rates.first?.ball, "master")
        XCTAssertEqual(sheet.rates.map { $0.chance }, sheet.rates.map { $0.chance }.sorted(by: >))
        XCTAssertEqual(sheet.rates.first { $0.ball == "net" }?.bonus.condition, .type("water"))
        XCTAssertEqual(sheet.rates.first { $0.ball == "poke" }?.chance ?? 0, 15.0 / 255, accuracy: 0.0001)
    }

    func test_repeatBall_onlyHelpsWhenTheSituationSaysItsBeenCaught() {
        let notCaught = makeHandler().handle(GetCatchRatesQuery(number: 0, game: .Scarlet))!
        let caught = makeHandler().handle(GetCatchRatesQuery(number: 0, game: .Scarlet, situation: CatchSituation(isRegisteredAsCaught: true)))!

        XCTAssertEqual(notCaught.rates.first { $0.ball == "repeat" }?.bonus.multiplier, 1)
        XCTAssertEqual(caught.rates.first { $0.ball == "repeat" }?.bonus, BallBonus(multiplier: 3.5, condition: .caughtBefore))
    }

    func test_unsupportedGames_haveNoRates() {
        XCTAssertNil(makeHandler().handle(GetCatchRatesQuery(number: 0, game: .LegendsArceus)))
        XCTAssertNil(makeHandler().handle(GetCatchRatesQuery(number: 0, game: .Gold)))
        XCTAssertFalse(GetCatchRatesHandler.supportedGames.contains(.LetsGoPikachu))
    }

    func test_bundledCatchData() {
        let data = PokemonCatchDataLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppDelegate.self)))

        XCTAssertEqual(data.findProfile(of: 0, formId: nil)?.catchRate, 45)
        XCTAssertEqual(data.findProfile(of: 149, formId: nil)?.catchRate, 3)
        XCTAssertEqual(data.findProfile(of: 18, formId: "alola")?.types, ["dark", "normal"])
        XCTAssertEqual(data.findProfile(of: 34, formId: nil)?.isInMoonStoneLine, true)
        XCTAssertEqual(data.findProfile(of: 172, formId: nil)?.isInMoonStoneLine, true)
        XCTAssertEqual(data.findProfile(of: 35, formId: nil)?.isInMoonStoneLine, true)
        XCTAssertEqual(data.findProfile(of: 0, formId: nil)?.isInMoonStoneLine, false)
        XCTAssertEqual(data.findProfile(of: 142, formId: nil)?.weightInKilograms, 460)
    }
}
