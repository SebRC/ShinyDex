import XCTest
@testable import ShinyDex

final class TrainingPlanTests: XCTestCase {
    private let fastHitter = BaseStats([60, 110, 60, 50, 60, 100])
    private let slowHitter = BaseStats([100, 120, 80, 50, 70, 30])
    private let specialWall = BaseStats([95, 40, 70, 45, 125, 50])

    private func makeEVs(_ values: [Int]) -> EffortValues {
        return EffortValues(encoded: values.map(String.init).joined(separator: ","))
    }

    // MARK: Suggestion

    func test_suggestsAFastAttacker_forAQuickPokemon() {
        XCTAssertEqual(TrainingPlan.suggestSpread(style: .physical, base: fastHitter, isTrickRoomBattler: false), .fastAttacker)
    }

    func test_suggestsABulkyAttacker_forASlowPokemon() {
        XCTAssertEqual(TrainingPlan.suggestSpread(style: .physical, base: slowHitter, isTrickRoomBattler: false), .bulkyAttacker)
    }

    func test_suggestsABulkyAttacker_forATrickRoomBattler() {
        XCTAssertEqual(TrainingPlan.suggestSpread(style: .physical, base: fastHitter, isTrickRoomBattler: true), .bulkyAttacker)
    }

    func test_suggestsAWall_whenItsDefensesFarOutclassItsAttack() {
        XCTAssertEqual(TrainingPlan.suggestSpread(style: .unknown, base: specialWall, isTrickRoomBattler: false), .wall)
    }

    func test_suggestsAFastAttacker_withoutBaseStats() {
        XCTAssertEqual(TrainingPlan.suggestSpread(style: .special, base: nil, isTrickRoomBattler: false), .fastAttacker)
    }

    // MARK: Targets

    func test_fastAttackerMaxesTheUsedAttackingStatAndSpeed() {
        let plan = TrainingPlan(spread: .fastAttacker, current: EffortValues(), style: .special, base: fastHitter)

        XCTAssertEqual(plan.targets, makeEVs([4, 0, 0, 252, 0, 252]))
        XCTAssertEqual(plan.remaining, 508)
    }

    func test_bulkyAttackerPutsTheLeftoverIntoTheBulkierDefense() {
        let plan = TrainingPlan(spread: .bulkyAttacker, current: EffortValues(), style: .physical, base: slowHitter)

        XCTAssertEqual(plan.targets, makeEVs([252, 252, 4, 0, 0, 0]))
    }

    func test_wallMaxesHPAndTheBulkierDefense() {
        let plan = TrainingPlan(spread: .wall, current: EffortValues(), style: .unknown, base: specialWall)

        XCTAssertEqual(plan.targets, makeEVs([252, 0, 4, 0, 252, 0]))
    }

    func test_mixedAttackerSplitsBetweenBothAttackingStats() {
        let plan = TrainingPlan(spread: .fastAttacker, current: EffortValues(), style: .mixed, base: BaseStats([60, 90, 60, 85, 60, 100]))

        XCTAssertEqual(plan.targets, makeEVs([4, 128, 0, 124, 0, 252]))
    }

    func test_mixedAttackerCommitsToTheStatItsNatureDoesNotLower() {
        let plan = TrainingPlan(spread: .fastAttacker, current: EffortValues(), style: .mixed, nature: .timid, base: fastHitter)

        XCTAssertEqual(plan.targets, makeEVs([4, 0, 0, 252, 0, 252]))
    }

    func test_mixedAttackerCommitsToAClearlyStrongerAttackingStat() {
        XCTAssertEqual(TrainingPlan.findAttackingStats(style: .mixed, base: BaseStats([50, 60, 50, 135, 50, 50])), [.specialAttack])
    }

    func test_unknownStyleUsesTheHigherAttackingBaseStat() {
        XCTAssertEqual(TrainingPlan.findAttackingStats(style: .unknown, base: BaseStats([50, 60, 50, 90, 50, 50])), [.specialAttack])
    }

    // MARK: Progress

    func test_reportsWhatIsLeftAndWhatIsOutsideThePlan() {
        let plan = TrainingPlan(spread: .fastAttacker, current: makeEVs([0, 100, 40, 0, 0, 252]), style: .physical, base: fastHitter)

        XCTAssertEqual(plan.stats[Stat.attack.rawValue].remaining, 152)
        XCTAssertEqual(plan.stats[Stat.hp.rawValue].remaining, 4)
        XCTAssertEqual(plan.stats[Stat.defense.rawValue].excess, 40)
        XCTAssertEqual(plan.stats[Stat.speed.rawValue].remaining, 0)
        XCTAssertEqual(plan.remaining, 156)
        XCTAssertEqual(plan.excess, 40)
        XCTAssertFalse(plan.isComplete)
    }

    func test_ignoresLeftoverEVsThatAddNoStatPoint() {
        let plan = TrainingPlan(spread: .fastAttacker, current: makeEVs([4, 252, 2, 0, 0, 252]), style: .physical, base: fastHitter)
        let overSpeed = TrainingPlan(spread: .fastAttacker, current: makeEVs([4, 252, 0, 0, 0, 254]), style: .physical, base: fastHitter)

        XCTAssertTrue(plan.isComplete)
        XCTAssertTrue(overSpeed.isComplete)
        XCTAssertEqual(overSpeed.stats[Stat.speed.rawValue].excess, 0)
    }

    func test_isComplete_whenTheEVsMatchThePlan() {
        let plan = TrainingPlan(spread: .fastAttacker, current: makeEVs([4, 252, 0, 0, 0, 252]), style: .physical, base: fastHitter)

        XCTAssertTrue(plan.isComplete)
    }

    // MARK: Handler

    func test_handlerSuggestsASpreadAndShowsStatsBeforeAndAfter() {
        let catches = InMemoryCatchRepository()
        let caught = Catch(id: UUID(), number: 0, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil,
                           isFailed: false, evs: EffortValues(), evolvedFrom: nil, nature: .hardy, ivs: makeIVs([31, 31, 31, 31, 31, 31]), formId: nil, moves: [1])
        catches.insert(caught)
        let handler = GetTrainingPlanHandler(catchRepository: catches,
                                             baseStats: PokemonBaseStats(statsByNumber: [0: SpeciesBaseStats(standard: fastHitter, statsByFormId: [:])]),
                                             moveCategories: MoveCategories(categoriesById: [1: .physical]))

        let plan = handler.handle(GetTrainingPlanQuery(catchId: CatchID(rawValue: caught.id)))!
        let attack = plan.stats[Stat.attack.rawValue]

        XCTAssertEqual(plan.suggestedSpread, .fastAttacker)
        XCTAssertEqual(plan.spread, .fastAttacker)
        XCTAssertEqual(attack.remaining, 252)
        XCTAssertEqual(attack.value, 130)
        XCTAssertEqual(attack.plannedValue, 162)
        XCTAssertEqual(handler.handle(GetTrainingPlanQuery(catchId: CatchID(rawValue: caught.id), spread: .wall))?.spread, .wall)
    }
}
