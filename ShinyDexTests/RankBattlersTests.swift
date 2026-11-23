import XCTest
@testable import ShinyDex

final class RankBattlersTests: XCTestCase {
    private let bulbasaur = 0, charmander = 1, squirtle = 2
    private let tackle = 1, ember = 2
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let baseStats = PokemonBaseStats(statsByNumber: [
        0: SpeciesBaseStats(standard: BaseStats([45, 49, 49, 65, 65, 45]), statsByFormId: [:]),
        1: SpeciesBaseStats(standard: BaseStats([39, 52, 43, 60, 50, 65]), statsByFormId: ["mega": BaseStats([78, 130, 111, 130, 85, 100])])
    ])
    private let moveCategories = MoveCategories(categoriesById: [1: .physical, 2: .special])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Charmander", "Squirtle"])
        catches = InMemoryCatchRepository()
    }

    @discardableResult
    private func addCatch(of number: Int, game: Games = .Scarlet, ivs: IndividualValues, nature: Nature? = nil, formId: String? = nil, moves: [Int] = [], isFailed: Bool = false) -> Catch {
        let caught = Catch(id: UUID(), number: number, caughtBall: "poke", game: game, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil,
                           isFailed: isFailed, evs: EffortValues(), evolvedFrom: nil, nature: nature, ivs: ivs, formId: formId, moves: moves)
        catches.insert(caught)
        return caught
    }

    private func rank(by ranking: BattlerRanking = .relevantIVs, level: BattleLevel = .fifty, bestOfEachSpecies: Bool = false) -> BattlerRankings {
        return RankBattlersHandler(catchRepository: catches, pokemonRepository: pokemon, baseStats: baseStats, moveCategories: moveCategories)
            .handle(RankBattlersQuery(ranking: ranking, level: level, showsBestOfEachSpecies: bestOfEachSpecies))
    }

    func test_onlyCatchesWithIVsFromGenerationThreeOnAreRanked() {
        addCatch(of: bulbasaur, ivs: makeIVs([31, 31, 31, 31, 31, 31]))
        addCatch(of: charmander, ivs: IndividualValues())
        addCatch(of: squirtle, game: .Crystal, ivs: makeIVs([15, 15, 15, 15, 15, 15]))
        addCatch(of: squirtle, ivs: makeIVs([31, 31, 31, 31, 31, 31]), isFailed: true)

        let rankings = rank()

        XCTAssertEqual(rankings.battlers.map { $0.number }, [bulbasaur])
        XCTAssertEqual(rankings.catchesWithoutIVs, 1)
        XCTAssertEqual(rankings.olderGenerationCatches, 1)
    }

    func test_rankingsSortByTheChosenScore() {
        let fivePerfect = addCatch(of: bulbasaur, ivs: makeIVs([31, 31, 31, 31, 31, 0]))
        let highTotal = addCatch(of: charmander, ivs: makeIVs([30, 30, 30, 30, 30, 30]))

        XCTAssertEqual(rank(by: .perfectIVs).battlers.map { $0.id.rawValue }, [fivePerfect.id, highTotal.id])
        XCTAssertEqual(rank(by: .ivTotal).battlers.map { $0.id.rawValue }, [highTotal.id, fivePerfect.id])
    }

    func test_relevantIVs_useTheStyleFromTheMoves() {
        let lowSpecialAttack = makeIVs([31, 31, 31, 0, 31, 31])
        let physical = addCatch(of: bulbasaur, ivs: lowSpecialAttack, moves: [tackle])
        let special = addCatch(of: charmander, ivs: lowSpecialAttack, moves: [ember])

        let battlers = rank().battlers

        XCTAssertEqual(battlers.map { $0.id.rawValue }, [physical.id, special.id])
        XCTAssertEqual(battlers[0].style, .physical)
        XCTAssertEqual(battlers[0].stats.filter { $0.isLessRelevant }.map { $0.stat }, [.specialAttack])
        XCTAssertEqual(battlers[1].stats.filter { $0.isLessRelevant }.map { $0.stat }, [.attack])
    }

    func test_statsAreCalculatedFromTheFormsBaseStats_atTheChosenLevel() {
        addCatch(of: charmander, ivs: makeIVs([31, 31, 31, 31, 31, 31]), formId: "mega")

        let atFifty = rank(level: .fifty).battlers[0].stats.map { $0.value }
        let atHundred = rank(level: .hundred).battlers[0].stats.map { $0.value }

        XCTAssertEqual(atFifty[Stat.hp.rawValue], 153)
        XCTAssertEqual(atHundred[Stat.hp.rawValue], 297)
        XCTAssertEqual(atHundred[Stat.attack.rawValue], 296)
    }

    func test_bestOfEachSpecies_keepsTheTopRankedCatch_andCountsTheRest() {
        let best = addCatch(of: bulbasaur, ivs: makeIVs([31, 31, 31, 31, 31, 31]))
        addCatch(of: bulbasaur, ivs: makeIVs([10, 10, 10, 10, 10, 10]))
        addCatch(of: bulbasaur, ivs: makeIVs([20, 20, 20, 20, 20, 20]))
        addCatch(of: charmander, ivs: makeIVs([25, 25, 25, 25, 25, 25]))

        let battlers = rank(bestOfEachSpecies: true).battlers

        XCTAssertEqual(battlers.map { $0.number }, [bulbasaur, charmander])
        XCTAssertEqual(battlers[0].id.rawValue, best.id)
        XCTAssertEqual(battlers.map { $0.duplicateCount }, [2, 0])
    }

    func test_hyperTraining_followsTheGameTheCatchIsIn() {
        let ivs = makeIVs([31, 25, 31, 31, 31, 31])
        addCatch(of: bulbasaur, game: .Scarlet, ivs: ivs)
        addCatch(of: charmander, game: .Platinum, ivs: ivs)
        addCatch(of: squirtle, game: .LegendsArceus, ivs: ivs)

        let badgesByNumber = Dictionary(uniqueKeysWithValues: rank().battlers.map { ($0.number, $0.badges) })

        XCTAssertTrue(badgesByNumber[bulbasaur]!.contains(.hyperTrainingCandidate([.attack])))
        XCTAssertFalse(badgesByNumber[charmander]!.contains(.hyperTrainingCandidate([.attack])))
        XCTAssertFalse(badgesByNumber[squirtle]!.contains(.hyperTrainingCandidate([.attack])))
    }

    func test_battleReady_followsWhatTheCatchesGameCanChange() {
        let weakIVs = makeIVs([12, 20, 5, 9, 14, 3])
        let platinum = addCatch(of: bulbasaur, game: .Platinum, ivs: weakIVs, nature: .modest, moves: [tackle, 3, 4, 5])
        let scarlet = addCatch(of: charmander, game: .Scarlet, ivs: weakIVs, nature: .modest, moves: [tackle, 3, 4, 5])
        let legendsArceus = addCatch(of: squirtle, game: .LegendsArceus, ivs: weakIVs, nature: .modest, moves: [tackle, 3, 4, 5])
        for caught in [platinum, scarlet, legendsArceus] {
            caught.evs = makeEVs([4, 252, 0, 0, 0, 252])
            catches.update(caught)
        }

        let readyById = Dictionary(uniqueKeysWithValues: rank().battlers.map { ($0.id.rawValue, $0.badges.contains(.battleReady)) })

        XCTAssertEqual(readyById[platinum.id], true)
        XCTAssertEqual(readyById[scarlet.id], false)
        XCTAssertEqual(readyById[legendsArceus.id], false)
    }

        func test_hiddenPowerType_isIncluded() {
        addCatch(of: bulbasaur, ivs: makeIVs([31, 30, 31, 30, 31, 30]))

        XCTAssertEqual(rank().battlers[0].hiddenPowerType, "Fire")
    }

    func test_bundledBaseStats_coverEverySpeciesAndFormsThatDiffer() {
        let loaded = PokemonBaseStatsLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppDelegate.self)))

        XCTAssertEqual(loaded.findStats(of: 444, formId: nil), BaseStats([108, 130, 95, 80, 85, 102]))
        XCTAssertEqual(loaded.findStats(of: 18, formId: "alola"), BaseStats([30, 56, 35, 25, 35, 72]))
        XCTAssertEqual(loaded.findStats(of: 200, formId: "b"), loaded.findStats(of: 200, formId: nil))
        XCTAssertNotNil(loaded.findStats(of: 1024, formId: nil))
    }

    func test_bundledMoveCategories_matchTheMoveData() {
        let loaded = MoveCategoriesLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppDelegate.self)))

        XCTAssertEqual(loaded.findCategory(of: 89), .physical)
        XCTAssertEqual(loaded.findCategory(of: 85), .special)
        XCTAssertEqual(loaded.findCategory(of: 14), .status)
    }
}
