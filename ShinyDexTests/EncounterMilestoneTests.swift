import XCTest
@testable import ShinyDex

final class EncounterMilestoneTests: XCTestCase {
    // MARK: Domain

    func test_crossingTheOdds_isAnOddsMilestone() {
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 4095, to: 4096, shinyOdds: 4096, countsTowardsOdds: true), .oddsMultiple(1))
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 8190, to: 8193, shinyOdds: 4096, countsTowardsOdds: true), .oddsMultiple(2))
    }

    func test_everyThousandEncounters_isAMilestone() {
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 999, to: 1000, shinyOdds: 4096, countsTowardsOdds: true), .encounters(1000))
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 2998, to: 3003, shinyOdds: 4096, countsTowardsOdds: true), .encounters(3000))
    }

    func test_oddsMilestones_winWhenBothAreCrossed() {
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 1999, to: 2000, shinyOdds: 1000, countsTowardsOdds: true), .oddsMultiple(2))
    }

    func test_chainHunts_onlyGetEncounterMilestones() {
        XCTAssertNil(EncounterMilestone.findCrossed(from: 511, to: 512, shinyOdds: 512, countsTowardsOdds: false))
        XCTAssertEqual(EncounterMilestone.findCrossed(from: 999, to: 1000, shinyOdds: 1000, countsTowardsOdds: false), .encounters(1000))
    }

    func test_noMilestone_withoutCrossingOne_orWhenCountingDown() {
        XCTAssertNil(EncounterMilestone.findCrossed(from: 1000, to: 1001, shinyOdds: 4096, countsTowardsOdds: true))
        XCTAssertNil(EncounterMilestone.findCrossed(from: 1001, to: 999, shinyOdds: 4096, countsTowardsOdds: true))
        XCTAssertNil(EncounterMilestone.findCrossed(from: 0, to: 1, shinyOdds: 0, countsTowardsOdds: true))
    }

    // MARK: Handlers

    private func makeChangeEncounters(_ pokemon: InMemoryPokemonRepository) -> ChangeEncountersHandler {
        return ChangeEncountersHandler(pokemonRepository: pokemon, catchRepository: InMemoryCatchRepository(), ledgerRepository: InMemoryEncounterLedgerRepository(),
                                       dailyEncountersRepository: InMemoryDailyEncountersRepository(), odds: OddsService())
    }

    func test_counting_reportsTheMilestoneItReaches_butTypingACountDoesNot() {
        let pokemon = InMemoryPokemonRepository(names: ["Bulbasaur"])
        let changeEncounters = makeChangeEncounters(pokemon)
        changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .set(999)))
        let odds = pokemon.get(number: 0)!.shinyOdds

        XCTAssertEqual(changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .increment)), ReachedMilestone(number: 0, pokemonName: "Bulbasaur", kind: .encounters(1000)))
        XCTAssertNil(changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .increment)))
        XCTAssertNil(changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .set(odds))))

        changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .set(odds - 1)))
        XCTAssertEqual(changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .increment)), ReachedMilestone(number: 0, pokemonName: "Bulbasaur", kind: .oddsMultiple(1)))
        XCTAssertNil(changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .decrement)))
    }

    func test_incrementAll_reportsEveryPokemonThatReachedAMilestone() {
        let pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Charmander", "Squirtle"])
        let hunts = InMemoryHuntRepository()
        let changeEncounters = makeChangeEncounters(pokemon)
        CreateHuntHandler(huntRepository: hunts, pokemonRepository: pokemon).handle(CreateHuntCommand(name: "Starters", pokemonNumbers: [0, 1, 2]))
        changeEncounters.handle(ChangeEncountersCommand(number: 0, change: .set(999)))
        changeEncounters.handle(ChangeEncountersCommand(number: 2, change: .set(1999)))
        let huntId = HuntID(rawValue: hunts.getAll()[0].id)

        let milestones = IncrementAllInHuntHandler(huntRepository: hunts, changeEncounters: changeEncounters).handle(IncrementAllInHuntCommand(huntId: huntId))

        XCTAssertEqual(milestones, [
            ReachedMilestone(number: 0, pokemonName: "Bulbasaur", kind: .encounters(1000)),
            ReachedMilestone(number: 2, pokemonName: "Squirtle", kind: .encounters(2000))
        ])
    }

    // MARK: Text

    func test_messages() {
        let atOdds = ReachedMilestone(number: 6, pokemonName: "Squirtle", kind: .oddsMultiple(1))
        let pastOdds = ReachedMilestone(number: 6, pokemonName: "Squirtle", kind: .oddsMultiple(2))
        let thousands = ReachedMilestone(number: 6, pokemonName: "Squirtle", kind: .encounters(3000))

        XCTAssertEqual(MilestoneText.makeMessage(for: atOdds), "Squirtle has reached its odds. A shiny could be next!")
        XCTAssertEqual(MilestoneText.makeMessage(for: pastOdds), "Squirtle is at 2× its odds. Keep going!")
        XCTAssertEqual(MilestoneText.makeMessage(for: thousands), "Squirtle hit \(3000.grouped) encounters!")
        XCTAssertEqual(MilestoneText.makeShortLabel(for: atOdds), "At odds")
        XCTAssertEqual(MilestoneText.makeShortLabel(for: pastOdds), "2× odds")
        XCTAssertEqual(MilestoneText.makeShortLabel(for: thousands), "\(3000.grouped) encounters")
        XCTAssertTrue(atOdds.isOddsMilestone)
        XCTAssertFalse(thousands.isOddsMilestone)
    }

    // MARK: Abbreviated counts

    func test_abbreviated_shortensMillionsAndBillions_toThreeSignificantDigits() {
        let english = Locale(identifier: "en_US")

        XCTAssertEqual(1_450_000.abbreviated(in: english), "1.45M")
        XCTAssertEqual(12_345_678.abbreviated(in: english), "12.3M")
        XCTAssertEqual(2_000_000.abbreviated(in: english), "2M")
        XCTAssertEqual(1_230_000_000.abbreviated(in: english), "1.23B")
        XCTAssertEqual(1_450_000.abbreviated(in: Locale(identifier: "da_DK")), "1,45M")
    }

    func test_abbreviated_keepsSmallerCountsInFull() {
        XCTAssertEqual(999_999.abbreviated(), 999_999.grouped)
        XCTAssertEqual(4_096.abbreviated(), 4_096.grouped)
    }
}
