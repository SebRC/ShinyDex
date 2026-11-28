import XCTest
@testable import ShinyDex

final class HuntLuckTextTests: XCTestCase {
    private func makeDetails(encounters: Int, shinyOdds: Int = 4096, usesChain: Bool = false) -> PokemonDetails {
        let settings = HuntSettings(game: .Scarlet, generation: 9, huntMethod: .Encounters, isShinyCharmActive: false)
        return PokemonDetails(number: 0, name: "Bulbasaur", encounters: encounters, increment: 1, settings: settings, shinyOdds: shinyOdds,
                              chain: 0, usesChain: usesChain, probability: Double.getProbability(encounters: encounters, odds: shinyOdds),
                              caughtBall: "none", catchCount: 0, isBeingHunted: true)
    }

    func test_withoutEncounters_showsNoDetails() {
        let luck = HuntLuckText(pokemon: makeDetails(encounters: 0))

        XCTAssertNil(luck.chanceDetail)
        XCTAssertNil(luck.oddsDetail)
    }

    func test_belowEvenChance_saysHowManyHuntsGoLonger() {
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 1000)).chanceDetail, "78% of hunts go longer")
    }

    func test_pastEvenChance_saysHowFewHuntsGoThisLong() {
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 6600)).chanceDetail, "Only 20% of hunts go this long")
    }

    func test_veryLongHunts_keepADecimal() {
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 20_000)).chanceDetail, "Only 0.7% of hunts go this long")
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 2)).chanceDetail, "99.9% of hunts go longer")
    }

    func test_oddsDetail_appearsOncePastOdds() {
        XCTAssertNil(HuntLuckText(pokemon: makeDetails(encounters: 4095)).oddsDetail)
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 4096)).oddsDetail, "1.0× past odds")
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 4500)).oddsDetail, "1.1× past odds")
        XCTAssertEqual(HuntLuckText(pokemon: makeDetails(encounters: 6600)).oddsDetail, "1.6× past odds")
    }

    func test_chainHunts_haveNoOddsDetail_sinceTheirOddsChangeWithTheChain() {
        XCTAssertNil(HuntLuckText(pokemon: makeDetails(encounters: 9000, shinyOdds: 512, usesChain: true)).oddsDetail)
    }
}

final class CatchLuckTextTests: XCTestCase {
    func test_describe_saysLuckierThan_whenFoundBeforeHalfOfHunts() {
        XCTAssertEqual(CatchLuckText.describe(chanceOfFindingSooner: 18), "Luckier than 82% of hunts at these odds")
    }

    func test_describe_saysTookLonger_whenFoundAfterHalfOfHunts() {
        XCTAssertEqual(CatchLuckText.describe(chanceOfFindingSooner: 76.4), "Took longer than 76% of hunts at these odds")
    }

    func test_formatRank_givesTheShareOfHuntsThatTookLonger_orFinishedSooner() {
        XCTAssertEqual(CatchLuckText.formatRank(chanceOfFindingSooner: 3.2), "Top 3%")
        XCTAssertEqual(CatchLuckText.formatRank(chanceOfFindingSooner: 99.8), "Bottom 0.2%")
    }

    func test_formatPercent_keepsOneDecimalNearTheEnds_withoutRoundingToZeroOrAHundred() {
        XCTAssertEqual(CatchLuckText.formatPercent(99.97), "99.9%")
        XCTAssertEqual(CatchLuckText.formatPercent(99.6), "99.6%")
        XCTAssertEqual(CatchLuckText.formatPercent(0.04), "0.1%")
        XCTAssertEqual(CatchLuckText.formatPercent(42.5), "43%")
    }
}
