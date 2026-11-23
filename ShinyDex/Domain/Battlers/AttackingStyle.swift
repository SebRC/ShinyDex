import Foundation

enum AttackingStyle: Equatable {
    case physical
    case special
    case mixed
    case unknown

    var usedAttackingStat: Stat? {
        switch self {
        case .physical: return .attack
        case .special: return .specialAttack
        case .mixed, .unknown: return nil
        }
    }

    var lessRelevantStat: Stat? {
        switch self {
        case .physical: return .specialAttack
        case .special: return .attack
        case .mixed, .unknown: return nil
        }
    }

    static func determine(from moveCategories: [MoveCategory], nature: Nature?) -> AttackingStyle {
        let usesPhysical = moveCategories.contains(.physical)
        let usesSpecial = moveCategories.contains(.special)
        switch (usesPhysical, usesSpecial) {
        case (true, true): return .mixed
        case (true, false): return .physical
        case (false, true): return .special
        case (false, false): return determine(from: nature)
        }
    }

    fileprivate static func determine(from nature: Nature?) -> AttackingStyle {
        switch (nature?.raisedStat, nature?.loweredStat) {
        case (.attack?, _), (_, .specialAttack?): return .physical
        case (.specialAttack?, _), (_, .attack?): return .special
        default: return .unknown
        }
    }
}
