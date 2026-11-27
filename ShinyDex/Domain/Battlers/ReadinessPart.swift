import Foundation

enum ReadinessFactor: CaseIterable {
    case nature
    case ivs
    case evs
    case moves
    case ability
}

enum ReadinessImprovement: Equatable {
    case logNature
    case changeNature(lowering: Stat, usesMint: Bool)
    case commitToOneAttackingStat
    case logIVs([Stat])
    case raiseIVs([Stat], usesHyperTraining: Bool)
    case trainEVs(remaining: Int)
    case moveWastedEVs(Int)
    case teachMoves(Int)
    case logAbility
}

struct ReadinessPart: Equatable {
    let factor: ReadinessFactor
    let earned: Int
    let maximum: Int
    let improvements: [ReadinessImprovement]
}
