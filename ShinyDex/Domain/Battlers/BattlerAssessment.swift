import Foundation

enum NatureFit: Equatable {
    case ideal
    case fine
    case against
    case unknown
}

enum BattlerBadge: Equatable {
    case battleReady
    case needsEVTraining(remaining: Int)
    case wastedEVs(Int)
    case natureAgainstIt
    case hyperTrainingCandidate([Stat])
    case trickRoom
}

struct BattlerAssessment {
    static let lessRelevantWeight = 0.25
    static let maximumTrickRoomSpeedIV = 2
    static let maximumHyperTrainingStats = 3
    static let minimumReadyRelevantIVPercent = 80
    static let fullyTrainedEffortValues = EffortValues.maximumUsefulPerStat * 2 + 4

    fileprivate static let naturePoints = 25
    fileprivate static let ivPoints = 35
    fileprivate static let evPoints = 25
    fileprivate static let movePoints = 10
    fileprivate static let abilityPoints = 5

    let ivs: IndividualValues
    let evs: EffortValues
    let nature: Nature?
    let style: AttackingStyle
    let moveCount: Int
    let hasAbility: Bool
    let canHyperTrain: Bool
    let canChangeNature: Bool

    init(ivs: IndividualValues, evs: EffortValues, nature: Nature?, style: AttackingStyle, moveCount: Int, hasAbility: Bool, canHyperTrain: Bool, canChangeNature: Bool) {
        self.ivs = ivs
        self.evs = evs
        self.nature = nature
        self.style = style
        self.moveCount = moveCount
        self.hasAbility = hasAbility
        self.canHyperTrain = canHyperTrain
        self.canChangeNature = canChangeNature
    }

    var ivTotal: Int {
        return ivs.values.compactMap { $0 }.reduce(0, +)
    }

    var perfectCount: Int {
        return ivs.perfectCount
    }

    var hasAllIVs: Bool {
        return !ivs.values.contains(nil)
    }

    var relevantIVPercent: Int {
        var weightedTotal = 0.0
        var weightedMaximum = 0.0
        for stat in Stat.allCases {
            let weight = stat == style.lessRelevantStat ? BattlerAssessment.lessRelevantWeight : 1
            weightedTotal += Double(ivs[stat] ?? 0) * weight
            weightedMaximum += Double(IndividualValues.range.upperBound) * weight
        }
        return Int((weightedTotal / weightedMaximum * 100).rounded())
    }

    var natureFit: NatureFit {
        guard let nature = nature else { return .unknown }
        guard let raised = nature.raisedStat, let lowered = nature.loweredStat else { return .fine }
        if (raised == style.lessRelevantStat || lowered == style.usedAttackingStat) {
            return .against
        }
        return lowered == style.lessRelevantStat ? .ideal : .fine
    }

    var usefulEffortValues: Int {
        return evs.total - wastedEffortValues
    }

    var wastedEffortValues: Int {
        return evs.wasted
    }

    var isFullyTrained: Bool {
        return usefulEffortValues >= BattlerAssessment.fullyTrainedEffortValues
    }

    var isTrickRoomBattler: Bool {
        guard nature?.loweredStat == .speed, let speed = ivs[.speed] else { return false }
        return speed <= BattlerAssessment.maximumTrickRoomSpeedIV
    }

    var readiness: Int {
        return readinessParts.map { $0.earned }.reduce(0, +)
    }

    var readinessParts: [ReadinessPart] {
        return ReadinessFactor.allCases.map(makeReadinessPart)
    }

    var hyperTrainingStats: [Stat] {
        guard canHyperTrain, hasAllIVs else { return [] }
        return Stat.allCases.filter { stat in
            let isIgnored = stat == style.lessRelevantStat || (stat == .speed && isTrickRoomBattler)
            return !isIgnored && ivs[stat] != IndividualValues.range.upperBound
        }
    }

    var badges: [BattlerBadge] {
        var badges = [BattlerBadge]()
        if (isBattleReady) {
            badges.append(.battleReady)
        }
        if (isTrickRoomBattler) {
            badges.append(.trickRoom)
        }
        if (natureFit == .against) {
            badges.append(.natureAgainstIt)
        }
        if (!isFullyTrained) {
            badges.append(.needsEVTraining(remaining: EffortValues.maximumTotal - usefulEffortValues))
        }
        if (wastedEffortValues > 0) {
            badges.append(.wastedEVs(wastedEffortValues))
        }
        let statsToHyperTrain = hyperTrainingStats
        if ((1...BattlerAssessment.maximumHyperTrainingStats).contains(statsToHyperTrain.count)) {
            badges.append(.hyperTrainingCandidate(statsToHyperTrain))
        }
        return badges
    }

    fileprivate var isBattleReady: Bool {
        return hasReadyNature && hasReadyIVs && isFullyTrained && moveCount == Catch.maximumMoveCount
    }

    fileprivate var hasReadyNature: Bool {
        return !canChangeNature || natureFit == .ideal || natureFit == .fine
    }

    fileprivate var hasReadyIVs: Bool {
        return !canHyperTrain || (hasAllIVs && relevantIVPercent >= BattlerAssessment.minimumReadyRelevantIVPercent)
    }

    fileprivate func makeReadinessPart(for factor: ReadinessFactor) -> ReadinessPart {
        switch factor {
        case .nature:
            return ReadinessPart(factor: factor, earned: calculateNatureScore(), maximum: BattlerAssessment.naturePoints, improvements: findNatureImprovements())
        case .ivs:
            return ReadinessPart(factor: factor, earned: relevantIVPercent * BattlerAssessment.ivPoints / 100, maximum: BattlerAssessment.ivPoints, improvements: findIVImprovements())
        case .evs:
            let earned = min(usefulEffortValues, BattlerAssessment.fullyTrainedEffortValues) * BattlerAssessment.evPoints / BattlerAssessment.fullyTrainedEffortValues
            return ReadinessPart(factor: factor, earned: earned, maximum: BattlerAssessment.evPoints, improvements: findEVImprovements())
        case .moves:
            let knownMoves = min(moveCount, Catch.maximumMoveCount)
            let missingMoves = Catch.maximumMoveCount - knownMoves
            return ReadinessPart(factor: factor, earned: knownMoves * BattlerAssessment.movePoints / Catch.maximumMoveCount, maximum: BattlerAssessment.movePoints,
                                 improvements: missingMoves > 0 ? [.teachMoves(missingMoves)] : [])
        case .ability:
            return ReadinessPart(factor: factor, earned: hasAbility ? BattlerAssessment.abilityPoints : 0, maximum: BattlerAssessment.abilityPoints,
                                 improvements: hasAbility ? [] : [.logAbility])
        }
    }

    fileprivate func calculateNatureScore() -> Int {
        switch natureFit {
        case .ideal: return BattlerAssessment.naturePoints
        case .fine: return BattlerAssessment.naturePoints * 3 / 5
        case .against, .unknown: return 0
        }
    }

    fileprivate func findNatureImprovements() -> [ReadinessImprovement] {
        switch natureFit {
        case .ideal: return []
        case .unknown: return [.logNature]
        case .fine, .against:
            guard let lessRelevantStat = style.lessRelevantStat else { return [.commitToOneAttackingStat] }
            return [.changeNature(lowering: lessRelevantStat, usesMint: canChangeNature)]
        }
    }

    fileprivate func findIVImprovements() -> [ReadinessImprovement] {
        let missingStats = Stat.allCases.filter { ivs[$0] == nil }
        let imperfectStats = Stat.allCases.filter { stat in
            let isIgnored = stat == style.lessRelevantStat || (stat == .speed && isTrickRoomBattler)
            return !isIgnored && ivs[stat].map { $0 < IndividualValues.range.upperBound } == true
        }
        var improvements = [ReadinessImprovement]()
        if (!missingStats.isEmpty) {
            improvements.append(.logIVs(missingStats))
        }
        if (!imperfectStats.isEmpty) {
            improvements.append(.raiseIVs(imperfectStats, usesHyperTraining: canHyperTrain))
        }
        return improvements
    }

    fileprivate func findEVImprovements() -> [ReadinessImprovement] {
        var improvements = [ReadinessImprovement]()
        if (!isFullyTrained) {
            improvements.append(.trainEVs(remaining: EffortValues.maximumTotal - usefulEffortValues))
        }
        if (wastedEffortValues > 0) {
            improvements.append(.moveWastedEVs(wastedEffortValues))
        }
        return improvements
    }
}

extension BattlerAssessment {
    init(caught: Catch, moveCategories: MoveCategories) {
        let style = AttackingStyle.determine(from: caught.moves.compactMap(moveCategories.findCategory), nature: caught.nature)
        self.init(ivs: caught.ivs, evs: caught.evs, nature: caught.nature, style: style, moveCount: caught.moves.count, hasAbility: caught.ability != nil,
                  canHyperTrain: caught.game.supportsHyperTraining, canChangeNature: caught.game.supportsMints)
    }
}
