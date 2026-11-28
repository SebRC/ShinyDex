import XCTest
@testable import ShinyDex

final class OddsCurveTests: XCTestCase {
    fileprivate let calculator = ShinyChanceCalculator(odds: OddsService(), probability: ProbabilityService())
    fileprivate let fullOdds = HuntConfiguration(game: .Scarlet, generation: 9, huntMethod: .Encounters, isShinyCharmActive: false)
    fileprivate let radar = HuntConfiguration(game: .Platinum, generation: 4, huntMethod: .Pokeradar, isShinyCharmActive: false)

    func test_milestones_areTheFirstEncounterReachingEachChance() {
        let curve = OddsCurve(encounters: 3000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.milestones.map { $0.encounters }, [2839, 9431, 18861])
        XCTAssertEqual(curve.milestones.map { $0.chance }, [50, 90, 99])
    }

    func test_current_matchesTheChanceSoFar() {
        let curve = OddsCurve(encounters: 3000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.current.encounters, 3000)
        XCTAssertEqual(curve.current.chance, calculator.calculateChance(encounters: 3000, chain: 0, configuration: fullOdds), accuracy: 0.0001)
    }

    func test_points_startAtZero_riseSteadily_andRunPastTheLastMilestone() {
        let curve = OddsCurve(encounters: 100, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertEqual(curve.points.first, OddsCurve.Point(encounters: 0, chance: 0))
        XCTAssertEqual(curve.points.count, OddsCurve.sampleCount + 1)
        XCTAssertGreaterThan(curve.lastEncounters, 18861)
        XCTAssertTrue(zip(curve.points, curve.points.dropFirst()).allSatisfy { $0.chance <= $1.chance })
    }

    func test_points_runPastTheCurrentCount_whenAHuntHasGoneBeyondEveryMilestone() {
        let curve = OddsCurve(encounters: 40000, chain: 0, configuration: fullOdds, calculator: calculator)

        XCTAssertGreaterThan(curve.lastEncounters, 40000)
    }

    func test_chainHunts_assumeTheChainKeepsGrowing_soMilestonesComeSoonerThanAtBaseOdds() {
        let base = OddsCurve(encounters: 0, chain: 0, configuration: HuntConfiguration(game: .Platinum, generation: 4, huntMethod: .Encounters, isShinyCharmActive: false), calculator: calculator)
        let chained = OddsCurve(encounters: 40, chain: 40, configuration: radar, calculator: calculator)

        XCTAssertEqual(chained.current.chance, calculator.calculateChance(encounters: 40, chain: 40, configuration: radar), accuracy: 0.0001)
        XCTAssertLessThan(chained.milestones[0].encounters, base.milestones[0].encounters)
    }
}
