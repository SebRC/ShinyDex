import Foundation

struct TeamAnalysis {
    struct Member {
        let types: [PokemonType]
        let attackingTypes: Set<PokemonType>
        let readiness: Int
    }

    struct Coverage: Equatable {
        let defender: PokemonType
        let hitters: Int
    }

    struct Weakness: Equatable {
        let attacker: PokemonType
        let weakCount: Int
        let resistCount: Int
    }

    static let sharedWeaknessMinimum = 2

    let coverage: [Coverage]
    let sharedWeaknesses: [Weakness]
    let averageReadiness: Int?

    init(members: [Member]) {
        coverage = PokemonType.allCases.map { defender in
            Coverage(defender: defender, hitters: members.filter { TeamAnalysis.hitsSuperEffectively($0, defender) }.count)
        }
        sharedWeaknesses = PokemonType.allCases
            .map { attacker in
                let multipliers = members.map { attacker.calculateMultiplier(against: $0.types) }
                return Weakness(attacker: attacker, weakCount: multipliers.filter { $0 > 1 }.count, resistCount: multipliers.filter { $0 < 1 }.count)
            }
            .filter { $0.weakCount >= TeamAnalysis.sharedWeaknessMinimum && $0.weakCount > $0.resistCount }
            .sorted { ($0.weakCount - $0.resistCount, $0.weakCount) > ($1.weakCount - $1.resistCount, $1.weakCount) }
        averageReadiness = members.isEmpty ? nil : Int((Double(members.map { $0.readiness }.reduce(0, +)) / Double(members.count)).rounded())
    }

    var coveredTypes: [PokemonType] {
        return coverage.filter { $0.hitters > 0 }.map { $0.defender }
    }

    var uncoveredTypes: [PokemonType] {
        return coverage.filter { $0.hitters == 0 }.map { $0.defender }
    }

    fileprivate static func hitsSuperEffectively(_ member: Member, _ defender: PokemonType) -> Bool {
        return member.attackingTypes.contains { $0.calculateMultiplier(against: defender) > 1 }
    }
}
