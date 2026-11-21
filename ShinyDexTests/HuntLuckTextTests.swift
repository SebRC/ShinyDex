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
