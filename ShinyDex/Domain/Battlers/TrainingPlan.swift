import Foundation

enum TrainingSpread: CaseIterable {
    case fastAttacker
    case bulkyAttacker
    case wall

    static let slowBaseSpeed = 50
    static let clearLeadMargin = 20
}

struct TrainingPlan: Equatable {
    static let mixedAttackShares = [128, 124]

    struct StatPlan: Equatable {
        let stat: Stat
        let current: Int
        let target: Int

        var remaining: Int {
            return max(target - current, 0)
        }

        var excess: Int {
            let addsStatPoints = current / EffortValues.perStatPoint > target / EffortValues.perStatPoint
            return addsStatPoints ? current - target : 0
        }
    }

    let spread: TrainingSpread
    let targets: EffortValues
    let stats: [StatPlan]

    var remaining: Int {
        return stats.map { $0.remaining }.reduce(0, +)
    }

    var excess: Int {
        return stats.map { $0.excess }.reduce(0, +)
    }

    var isComplete: Bool {
        return remaining == 0 && excess == 0
    }

    init(spread: TrainingSpread, current: EffortValues, style: AttackingStyle, nature: Nature? = nil, base: BaseStats?) {
        self.spread = spread
        let targets = TrainingPlan.makeTargets(for: spread, style: style, nature: nature, base: base)
        self.targets = targets
        stats = Stat.allCases.map { StatPlan(stat: $0, current: current[$0], target: targets[$0]) }
    }

    static func suggestSpread(style: AttackingStyle, nature: Nature? = nil, base: BaseStats?, isTrickRoomBattler: Bool) -> TrainingSpread {
        guard !isTrickRoomBattler else { return .bulkyAttacker }
        guard let base = base else { return .fastAttacker }
        let bestAttack = findAttackingStats(style: style, nature: nature, base: base).map { base[$0] }.max() ?? 0
        if bestAttack + TrainingSpread.clearLeadMargin < base[findBulkierDefense(base: base)] {
            return .wall
        }
        return base[.speed] <= TrainingSpread.slowBaseSpeed ? .bulkyAttacker : .fastAttacker
    }

    static func findAttackingStats(style: AttackingStyle, nature: Nature? = nil, base: BaseStats?) -> [Stat] {
        switch style {
        case .physical: return [.attack]
        case .special: return [.specialAttack]
        case .mixed: return findLeaningAttackingStat(nature: nature, base: base).map { [$0] } ?? [.attack, .specialAttack]
        case .unknown:
            guard let base = base else { return [.attack] }
            return [base[.specialAttack] > base[.attack] ? .specialAttack : .attack]
        }
    }

    fileprivate static func findLeaningAttackingStat(nature: Nature?, base: BaseStats?) -> Stat? {
        switch nature?.loweredStat {
        case .attack?: return .specialAttack
        case .specialAttack?: return .attack
        default: break
        }
        guard let base = base, abs(base[.attack] - base[.specialAttack]) >= TrainingSpread.clearLeadMargin else { return nil }
        return base[.attack] > base[.specialAttack] ? .attack : .specialAttack
    }

    fileprivate static func findBulkierDefense(base: BaseStats?) -> Stat {
        guard let base = base else { return .defense }
        return base[.specialDefense] > base[.defense] ? .specialDefense : .defense
    }

    fileprivate static func makeTargets(for spread: TrainingSpread, style: AttackingStyle, nature: Nature?, base: BaseStats?) -> EffortValues {
        let full = EffortValues.maximumUsefulPerStat
        let leftover = EffortValues.perStatPoint
        let attackingStats = findAttackingStats(style: style, nature: nature, base: base)
        let attackShares = attackingStats.count > 1 ? TrainingPlan.mixedAttackShares : [full]
        var targets = EffortValues()
        switch spread {
        case .fastAttacker:
            for (stat, share) in zip(attackingStats, attackShares) {
                targets = targets.setting(share, for: stat)
            }
            targets = targets.setting(full, for: .speed).setting(leftover, for: .hp)
        case .bulkyAttacker:
            targets = targets.setting(full, for: .hp)
            for (stat, share) in zip(attackingStats, attackShares) {
                targets = targets.setting(share, for: stat)
            }
            targets = targets.setting(leftover, for: findBulkierDefense(base: base))
        case .wall:
            let bulkier = findBulkierDefense(base: base)
            let other: Stat = bulkier == .defense ? .specialDefense : .defense
            targets = targets.setting(full, for: .hp).setting(full, for: bulkier).setting(leftover, for: other)
        }
        return targets
    }
}
