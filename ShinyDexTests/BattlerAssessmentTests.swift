import XCTest
@testable import ShinyDex

func makeIVs(_ values: [Int?]) -> IndividualValues {
    return zip(Stat.allCases, values).reduce(IndividualValues()) { ivs, pair in ivs.setting(pair.1, for: pair.0) }
}

func makeEVs(_ values: [Int]) -> EffortValues {
    return zip(Stat.allCases, values).reduce(EffortValues()) { evs, pair in evs.setting(pair.1, for: pair.0) }
}

final class BattlerAssessmentTests: XCTestCase {
    private let perfect = makeIVs([31, 31, 31, 31, 31, 31])
    private let attackSweeperEVs = makeEVs([4, 252, 0, 0, 0, 252])

    private func assess(ivs: IndividualValues, evs: EffortValues = EffortValues(), nature: Nature? = .adamant, style: AttackingStyle = .physical, moveCount: Int = 4, hasAbility: Bool = true, canHyperTrain: Bool = true, canChangeNature: Bool = true) -> BattlerAssessment {
        return BattlerAssessment(ivs: ivs, evs: evs, nature: nature, style: style, moveCount: moveCount, hasAbility: hasAbility, canHyperTrain: canHyperTrain, canChangeNature: canChangeNature)
    }

    // MARK: Attacking style

    func test_style_comesFromDamagingMoves_beforeNature() {
        XCTAssertEqual(AttackingStyle.determine(from: [.physical, .status], nature: .modest), .physical)
        XCTAssertEqual(AttackingStyle.determine(from: [.special], nature: .adamant), .special)
        XCTAssertEqual(AttackingStyle.determine(from: [.physical, .special], nature: nil), .mixed)
    }

    func test_style_fallsBackToNature_whenNoDamagingMovesAreKnown() {
        XCTAssertEqual(AttackingStyle.determine(from: [.status], nature: .adamant), .physical)
        XCTAssertEqual(AttackingStyle.determine(from: [], nature: .timid), .special)
        XCTAssertEqual(AttackingStyle.determine(from: [], nature: .bold), .special)
        XCTAssertEqual(AttackingStyle.determine(from: [], nature: .hardy), .unknown)
        XCTAssertEqual(AttackingStyle.determine(from: [], nature: nil), .unknown)
    }

    // MARK: IV scores

    func test_unusedAttackingStat_countsForLess_butStillCounts() {
        let lowSpecialAttack = makeIVs([31, 31, 31, 0, 31, 31])
        let lowAttack = makeIVs([31, 0, 31, 31, 31, 31])

        XCTAssertEqual(assess(ivs: perfect).relevantIVPercent, 100)
        XCTAssertEqual(assess(ivs: lowSpecialAttack, style: .physical).relevantIVPercent, 95)
        XCTAssertEqual(assess(ivs: lowAttack, style: .physical).relevantIVPercent, 81)
        XCTAssertEqual(assess(ivs: lowSpecialAttack, style: .mixed).relevantIVPercent, 83)
    }

    func test_lowSpeed_isNotTreatedAsPerfect_evenOnASlowNature() {
        let noSpeed = makeIVs([31, 31, 31, 31, 31, 0])

        let assessment = assess(ivs: noSpeed, nature: .brave)

        XCTAssertEqual(assessment.relevantIVPercent, 81)
        XCTAssertEqual(assessment.perfectCount, 5)
    }

    func test_unknownIVs_countAsZero_inTheRelevantScore_andAreLeftOutOfTheTotal() {
        let partial = makeIVs([31, 31, nil, nil, nil, nil])

        let assessment = assess(ivs: partial, style: .mixed)

        XCTAssertEqual(assessment.ivTotal, 62)
        XCTAssertEqual(assessment.relevantIVPercent, 33)
        XCTAssertFalse(assessment.hasAllIVs)
    }

    // MARK: Nature

    func test_natureFit_comparesTheNatureWithTheAttackingStyle() {
        XCTAssertEqual(assess(ivs: perfect, nature: .adamant, style: .physical).natureFit, .ideal)
        XCTAssertEqual(assess(ivs: perfect, nature: .jolly, style: .physical).natureFit, .ideal)
        XCTAssertEqual(assess(ivs: perfect, nature: .impish, style: .physical).natureFit, .ideal)
        XCTAssertEqual(assess(ivs: perfect, nature: .naive, style: .physical).natureFit, .fine)
        XCTAssertEqual(assess(ivs: perfect, nature: .serious, style: .physical).natureFit, .fine)
        XCTAssertEqual(assess(ivs: perfect, nature: .modest, style: .physical).natureFit, .against)
        XCTAssertEqual(assess(ivs: perfect, nature: .bold, style: .physical).natureFit, .against)
        XCTAssertEqual(assess(ivs: perfect, nature: .modest, style: .mixed).natureFit, .fine)
        XCTAssertEqual(assess(ivs: perfect, nature: nil).natureFit, .unknown)
    }

    // MARK: Readiness

    func test_readiness_isOneHundred_forAFullyBuiltBattler() {
        let assessment = assess(ivs: perfect, evs: attackSweeperEVs)

        XCTAssertEqual(assessment.readiness, 100)
        XCTAssertEqual(assessment.badges, [.battleReady])
    }

    func test_readiness_dropsForEachMissingPiece() {
        let untrained = assess(ivs: perfect, nature: .hardy, moveCount: 2, hasAbility: false)

        XCTAssertEqual(untrained.readiness, 15 + 35 + 0 + 5 + 0)
    }

    // MARK: Badges

    func test_trickRoomBadge_needsASpeedLoweringNature_andAVeryLowSpeedIV() {
        let slow = makeIVs([31, 31, 31, 31, 31, 0])
        let quick = makeIVs([31, 31, 31, 31, 31, 20])

        XCTAssertTrue(assess(ivs: slow, nature: .brave).badges.contains(.trickRoom))
        XCTAssertFalse(assess(ivs: quick, nature: .brave).badges.contains(.trickRoom))
        XCTAssertFalse(assess(ivs: slow, nature: .adamant).badges.contains(.trickRoom))
    }

    func test_hyperTraining_listsImperfectRelevantStats_andSkipsSpeedForTrickRoom() {
        let ivs = makeIVs([31, 25, 31, 0, 31, 0])

        XCTAssertEqual(assess(ivs: ivs, nature: .brave).hyperTrainingStats, [.attack])
        XCTAssertEqual(assess(ivs: ivs, nature: .adamant).hyperTrainingStats, [.attack, .speed])
        XCTAssertTrue(assess(ivs: ivs, nature: .brave).badges.contains(.hyperTrainingCandidate([.attack])))
    }

    func test_hyperTraining_isNotSuggested_forTooManyStatsOrUnknownIVs() {
        let weak = makeIVs([10, 10, 10, 10, 10, 10])
        let partial = makeIVs([31, 25, nil, 31, 31, 31])

        XCTAssertFalse(assess(ivs: weak).badges.contains { if case .hyperTrainingCandidate = $0 { return true }; return false })
        XCTAssertEqual(assess(ivs: partial).hyperTrainingStats, [])
    }

    func test_hyperTraining_isOnlySuggested_whenTheGameSupportsIt() {
        let ivs = makeIVs([31, 25, 31, 31, 31, 31])

        XCTAssertEqual(assess(ivs: ivs, canHyperTrain: false).hyperTrainingStats, [])
        XCTAssertFalse(assess(ivs: ivs, canHyperTrain: false).badges.contains { if case .hyperTrainingCandidate = $0 { return true }; return false })
    }

    func test_effortValueBadges_showWhatIsLeftAndWhatIsWasted() {
        let wasteful = makeEVs([0, 255, 0, 0, 0, 200])

        let badges = assess(ivs: perfect, evs: wasteful).badges

        XCTAssertTrue(badges.contains(.wastedEVs(3)))
        XCTAssertTrue(badges.contains(.needsEVTraining(remaining: 510 - 452)))
        XCTAssertFalse(badges.contains(.battleReady))
    }

    func test_battleReady_ignoresTheNature_whenTheGameHasNoMints() {
        XCTAssertTrue(assess(ivs: perfect, evs: attackSweeperEVs, nature: .modest, canChangeNature: false).badges.contains(.battleReady))
        XCTAssertTrue(assess(ivs: perfect, evs: attackSweeperEVs, nature: nil, canChangeNature: false).badges.contains(.battleReady))
    }

    func test_battleReady_ignoresTheIVs_whenTheGameHasNoHyperTraining() {
        let weak = makeIVs([10, 3, nil, 12, 8, 5])

        XCTAssertTrue(assess(ivs: weak, evs: attackSweeperEVs, canHyperTrain: false).badges.contains(.battleReady))
        XCTAssertFalse(assess(ivs: weak, evs: attackSweeperEVs, canHyperTrain: true).badges.contains(.battleReady))
    }

    func test_battleReady_stillNeedsTrainingAndMoves_whateverTheGame() {
        XCTAssertFalse(assess(ivs: perfect, canHyperTrain: false, canChangeNature: false).badges.contains(.battleReady))
        XCTAssertFalse(assess(ivs: perfect, evs: attackSweeperEVs, moveCount: 3, canHyperTrain: false, canChangeNature: false).badges.contains(.battleReady))
    }

    func test_natureAgainstItBadge() {
        XCTAssertTrue(assess(ivs: perfect, evs: attackSweeperEVs, nature: .modest).badges.contains(.natureAgainstIt))
        XCTAssertFalse(assess(ivs: perfect, evs: attackSweeperEVs, nature: .modest).badges.contains(.battleReady))
    }

    // MARK: Hidden Power

    func test_hiddenPower_followsTheIVs() {
        XCTAssertEqual(HiddenPower.findType(for: perfect), "Dark")
        XCTAssertEqual(HiddenPower.findType(for: makeIVs([31, 30, 31, 30, 31, 30])), "Fire")
        XCTAssertEqual(HiddenPower.findType(for: makeIVs([31, 30, 30, 31, 31, 31])), "Ice")
        XCTAssertEqual(HiddenPower.findType(for: makeIVs([30, 30, 30, 30, 30, 30])), "Fighting")
        XCTAssertNil(HiddenPower.findType(for: makeIVs([31, 31, 31, 31, 31, nil])))
    }

    func test_hiddenPowerPower_variesUpToGenerationFive_isSixtyAfter_andIsGoneFromGenerationEight() {
        let caesar = makeIVs([28, 24, 11, 27, 17, 16])

        XCTAssertEqual(HiddenPower(ivs: caesar, game: .Platinum), HiddenPower(ivs: caesar, game: .Black))
        XCTAssertEqual(HiddenPower(ivs: caesar, game: .Platinum)?.type, "Psychic")
        XCTAssertEqual(HiddenPower(ivs: caesar, game: .Platinum)?.power, 42)
        XCTAssertEqual(HiddenPower(ivs: caesar, game: .Sun)?.power, 60)
        XCTAssertEqual(HiddenPower(ivs: perfect, game: .Emerald)?.power, 70)
        XCTAssertEqual(HiddenPower(ivs: makeIVs([0, 0, 0, 0, 0, 0]), game: .Emerald)?.power, 30)
        XCTAssertNil(HiddenPower(ivs: caesar, game: .Sword))
        XCTAssertNil(HiddenPower(ivs: caesar, game: .Crystal))
        XCTAssertNil(HiddenPower(ivs: makeIVs([28, 24, 11, 27, 17, nil]), game: .Platinum))
    }

    // MARK: Stats

    func test_statCalculator_matchesKnownCompetitiveSpreads() {
        let garchomp = 444
        XCTAssertEqual(StatCalculator.calculate(.speed, of: garchomp, base: 102, iv: 31, ev: 252, nature: .jolly, level: 50), 169)
        XCTAssertEqual(StatCalculator.calculate(.speed, of: garchomp, base: 102, iv: 31, ev: 252, nature: .jolly, level: 100), 333)
        XCTAssertEqual(StatCalculator.calculate(.hp, of: garchomp, base: 108, iv: 31, ev: 0, nature: .jolly, level: 100), 357)
        XCTAssertEqual(StatCalculator.calculate(.attack, of: garchomp, base: 130, iv: 31, ev: 252, nature: .adamant, level: 50), 200)
    }

    func test_statCalculator_usesTheChosenLevel_andLeavesUnknownIVsBlank() {
        let base = BaseStats([108, 130, 95, 80, 85, 102])
        let ivs = makeIVs([31, 31, 31, 31, 31, nil])

        let atFifty = StatCalculator.calculateStats(of: 444, base: base, ivs: ivs, evs: attackSweeperEVs, nature: .jolly, level: .fifty)
        let atHundred = StatCalculator.calculateStats(of: 444, base: base, ivs: ivs, evs: attackSweeperEVs, nature: .jolly, level: .hundred)

        XCTAssertEqual(atFifty, [184, 182, 115, 90, 105, nil])
        XCTAssertEqual(atHundred, [358, 359, 226, 176, 206, nil])
    }

    func test_combinedStats_countTheUnusedAttackingStatAQuarter_unlessAskedToCountItFully() {
        let base = BaseStats([108, 130, 95, 80, 85, 102])

        let weighted = CombinedStats(of: 444, base: base, ivs: perfect, evs: attackSweeperEVs, nature: .jolly, level: .fifty, style: .physical, countsUnusedStatFully: false)
        let full = CombinedStats(of: 444, base: base, ivs: perfect, evs: attackSweeperEVs, nature: .jolly, level: .fifty, style: .physical, countsUnusedStatFully: true)

        XCTAssertEqual(weighted.total, 778)
        XCTAssertEqual(full.total, 184 + 182 + 115 + 90 + 105 + 169)
        XCTAssertFalse(weighted.isEstimated)
    }

    func test_combinedStats_assumeAnAverageIV_whereOneIsMissing() {
        let base = BaseStats([108, 130, 95, 80, 85, 102])
        let missingSpeed = makeIVs([31, 31, 31, 31, 31, nil])

        let combined = CombinedStats(of: 444, base: base, ivs: missingSpeed, evs: attackSweeperEVs, nature: .jolly, level: .fifty, style: .mixed, countsUnusedStatFully: false)

        XCTAssertEqual(combined.total, 184 + 182 + 115 + 90 + 105 + 160)
        XCTAssertTrue(combined.isEstimated)
    }

    func test_shedinja_alwaysHasOneHP() {
        XCTAssertEqual(StatCalculator.calculate(.hp, of: StatCalculator.shedinjaNumber, base: 1, iv: 31, ev: 252, nature: nil, level: 100), 1)
    }
}
