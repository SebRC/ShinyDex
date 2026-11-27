import Foundation

enum BattlerRanking: Int, CaseIterable {
    case relevantIVs
    case perfectIVs
    case ivTotal
    case readiness
    case combinedStats
}

struct BattlerStat: Equatable {
    let stat: Stat
    let iv: Int?
    let ev: Int
    let value: Int?
    let isLessRelevant: Bool
}

struct BattlerSummary: Equatable {
    let id: CatchID
    let number: Int
    let pokemonName: String
    let nickname: String?
    let formId: String?
    let formName: String?
    let caughtBall: String
    let game: Games
    let nature: Nature?
    let ability: String?
    let style: AttackingStyle
    let stats: [BattlerStat]
    let relevantIVPercent: Int
    let perfectCount: Int
    let ivTotal: Int
    let readiness: Int
    let readinessParts: [ReadinessPart]
    let hiddenPower: HiddenPower?
    let badges: [BattlerBadge]
    var combinedStats: CombinedStats? = nil
    var duplicateCount = 0
}

struct BattlerRankings: Equatable {
    let battlers: [BattlerSummary]
    let catchesWithoutIVs: Int
    let olderGenerationCatches: Int
}

struct StatLeader: Equatable {
    let id: CatchID
    let number: Int
    let pokemonName: String
    let nickname: String?
    let formId: String?
    let formName: String?
    let nature: Nature?
    let iv: Int
    let ev: Int
    let value: Int
    let trainedValue: Int?
    let trainedRank: Int?
}

struct StatRanking: Equatable {
    let leaders: [StatLeader]
    let catchesWithoutIV: Int
}
