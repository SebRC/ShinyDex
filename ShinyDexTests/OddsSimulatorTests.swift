import XCTest
@testable import ShinyDex

final class OddsSimulatorTests: XCTestCase {
    private let handler = SimulateOddsHandler(odds: OddsService(), probability: ProbabilityService())
    private let fullOddsScarlet = HuntSettings(game: .Scarlet, generation: 9, huntMethod: .Encounters, isShinyCharmActive: false)

    private func simulate(_ settings: HuntSettings, encounters: Int, selectingGame: Games? = nil) -> OddsSimulation {
        return handler.handle(SimulateOddsQuery(settings: settings, encounters: encounters, selectingGame: selectingGame))
    }

    private func assertMilestonesAreTheFirstEncounterReachingTheirChance(_ simulation: OddsSimulation, file: StaticString = #filePath, line: UInt = #line) {
        let calculator = ShinyChanceCalculator(odds: OddsService(), probability: ProbabilityService())
        let configuration = simulation.settings.configuration
        for milestone in simulation.milestones {
            guard let encounters = milestone.encounters else {
                XCTFail("\(milestone.percent)% should be reachable", file: file, line: line)
                continue
            }
            XCTAssertGreaterThanOrEqual(calculator.calculateChance(within: encounters, configuration: configuration), Double(milestone.percent), file: file, line: line)
            XCTAssertLessThan(calculator.calculateChance(within: encounters - 1, configuration: configuration), Double(milestone.percent), file: file, line: line)
        }
    }

    func test_fullOdds_givesTheChanceWithinTheEncounters() {
        let simulation = simulate(fullOddsScarlet, encounters: 4096)

        XCTAssertEqual(simulation.shinyOdds, 4096)
        XCTAssertEqual(simulation.chance, 63.21, accuracy: 0.01)
    }

    func test_milestones_areTheFirstEncountersReaching50_90And99Percent() {
        let simulation = simulate(fullOddsScarlet, encounters: 0)

        XCTAssertEqual(simulation.milestones.map { $0.percent }, [50, 90, 99])
        XCTAssertEqual(simulation.milestones.first?.encounters, 2839)
        assertMilestonesAreTheFirstEncounterReachingTheirChance(simulation)
    }

    func test_shinyCharm_bringsTheMilestonesForward() {
        let withoutCharm = simulate(fullOddsScarlet, encounters: 0)
        var charmSettings = fullOddsScarlet
        charmSettings.isShinyCharmActive = true

        let withCharm = simulate(charmSettings, encounters: 0)

        XCTAssertEqual(withCharm.shinyOdds, 1365)
        XCTAssertLessThan(withCharm.milestones[0].encounters!, withoutCharm.milestones[0].encounters!)
    }

    func test_chainMethods_haveNoChanceUntilTheChainIsBuilt_andThenImprove() {
        let sos = HuntSettings(game: .Sun, generation: 7, huntMethod: .SosChaining, isShinyCharmActive: false)

        XCTAssertEqual(simulate(sos, encounters: 30).chance, 0)
        XCTAssertGreaterThan(simulate(sos, encounters: 60).chance, 0)
        let simulation = simulate(sos, encounters: 0)
        XCTAssertEqual(simulation.chainThreshold, 30)
        assertMilestonesAreTheFirstEncounterReachingTheirChance(simulation)
    }

    func test_selectingAGameWithoutTheCharm_turnsTheCharmOff() {
        var charmSettings = fullOddsScarlet
        charmSettings.isShinyCharmActive = true

        let simulation = simulate(charmSettings, encounters: 100, selectingGame: .Red)

        XCTAssertEqual(simulation.settings.game, .Red)
        XCTAssertFalse(simulation.settings.isShinyCharmActive)
        XCTAssertEqual(simulation.shinyOdds, 8192)
    }

    func test_negativeEncounters_countAsNone() {
        let simulation = simulate(fullOddsScarlet, encounters: -5)

        XCTAssertEqual(simulation.encounters, 0)
        XCTAssertEqual(simulation.chance, 0)
    }
}
