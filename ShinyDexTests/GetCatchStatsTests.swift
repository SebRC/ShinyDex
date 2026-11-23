import XCTest
@testable import ShinyDex

final class GetCatchStatsTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let charmander = 0
    private let baseStats = PokemonBaseStats(statsByNumber: [
        0: SpeciesBaseStats(standard: BaseStats([39, 52, 43, 60, 50, 65]), statsByFormId: ["mega": BaseStats([78, 130, 111, 130, 85, 100])])
    ])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Charmander"])
        catches = InMemoryCatchRepository()
    }

    private func addCatch(ivs: IndividualValues, evs: EffortValues = EffortValues(), nature: Nature? = nil, formId: String? = nil, level: Int? = nil) -> CatchID {
        let caught = Catch(id: UUID(), number: charmander, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil,
                           isFailed: false, evs: evs, evolvedFrom: nil, nature: nature, ivs: ivs, formId: formId, level: level)
        catches.insert(caught)
        return CatchID(rawValue: caught.id)
    }

    private func getStats(of id: CatchID) -> CatchStatSheet? {
        return GetCatchStatsHandler(catchRepository: catches, pokemonRepository: pokemon, baseStats: baseStats).handle(GetCatchStatsQuery(catchId: id))
    }

    private func setLevel(of id: CatchID, to level: Int?) throws {
        try UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(UpdateCatchCommand(catchId: id, change: .level(level)))
    }

    func test_statsUseLevelFifty_untilALevelIsSaved() throws {
        let id = addCatch(ivs: makeIVs([31, 31, 31, 31, 31, 31]), evs: makeEVs([0, 252, 0, 0, 0, 0]), nature: .adamant)
        XCTAssertEqual(getStats(of: id)?.level, 50)
        XCTAssertEqual(getStats(of: id)?.lines.map { $0.value }, [114, 114, 63, 72, 70, 85])

        try setLevel(of: id, to: 100)

        XCTAssertEqual(catches.get(id: id.rawValue)?.level, 100)
        XCTAssertEqual(getStats(of: id)?.level, 100)
        XCTAssertEqual(getStats(of: id)?.lines.map { $0.value }, [219, 223, 122, 140, 136, 166])
    }

    func test_savedLevelIsKeptBetweenOneAndOneHundred() throws {
        let id = addCatch(ivs: makeIVs([31, 31, 31, 31, 31, 31]))

        try setLevel(of: id, to: 0)
        XCTAssertEqual(getStats(of: id)?.level, 1)
        XCTAssertEqual(getStats(of: id)?.lines.first?.value, 12)

        try setLevel(of: id, to: 250)
        XCTAssertEqual(getStats(of: id)?.level, 100)
    }

    func test_statsWithUnknownIVsAreLeftBlank_andBaseStatsFollowTheForm() {
        let id = addCatch(ivs: makeIVs([31, nil, 31, 31, 31, 31]), formId: "mega", level: 50)

        let lines = getStats(of: id)!.lines

        XCTAssertNil(lines[Stat.attack.rawValue].value)
        XCTAssertEqual(lines.map { $0.base }, [78, 130, 111, 130, 85, 100])
        XCTAssertEqual(lines[Stat.hp.rawValue].value, 153)
    }
}
