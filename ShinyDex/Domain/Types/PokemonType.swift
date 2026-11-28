import Foundation

enum PokemonType: Int, CaseIterable {
    case normal = 1, fighting, flying, poison, ground, rock, bug, ghost, steel, fire, water, grass, electric, psychic, ice, dragon, dark, fairy

    static let superEffective = 2.0
    static let notVeryEffective = 0.5
    static let noEffect = 0.0

    init?(name: String) {
        guard let type = PokemonType.allCases.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { return nil }
        self = type
    }

    var name: String {
        return String(describing: self).capitalized
    }

    func calculateMultiplier(against defender: PokemonType) -> Double {
        let matchup = PokemonType.matchups[self]!
        if (matchup.noEffect.contains(defender)) {
            return PokemonType.noEffect
        }
        if (matchup.superEffective.contains(defender)) {
            return PokemonType.superEffective
        }
        return matchup.notVeryEffective.contains(defender) ? PokemonType.notVeryEffective : 1
    }

    func calculateMultiplier(against defenders: [PokemonType]) -> Double {
        return defenders.reduce(1) { $0 * calculateMultiplier(against: $1) }
    }

    // MARK: Chart

    fileprivate struct Matchup {
        let superEffective: Set<PokemonType>
        let notVeryEffective: Set<PokemonType>
        var noEffect: Set<PokemonType> = []
    }

    fileprivate static let matchups: [PokemonType: Matchup] = [
        .normal: Matchup(superEffective: [], notVeryEffective: [.rock, .steel], noEffect: [.ghost]),
        .fighting: Matchup(superEffective: [.normal, .rock, .steel, .ice, .dark], notVeryEffective: [.flying, .poison, .bug, .psychic, .fairy], noEffect: [.ghost]),
        .flying: Matchup(superEffective: [.fighting, .bug, .grass], notVeryEffective: [.rock, .steel, .electric]),
        .poison: Matchup(superEffective: [.grass, .fairy], notVeryEffective: [.poison, .ground, .rock, .ghost], noEffect: [.steel]),
        .ground: Matchup(superEffective: [.poison, .rock, .steel, .fire, .electric], notVeryEffective: [.bug, .grass], noEffect: [.flying]),
        .rock: Matchup(superEffective: [.flying, .bug, .fire, .ice], notVeryEffective: [.fighting, .ground, .steel]),
        .bug: Matchup(superEffective: [.grass, .psychic, .dark], notVeryEffective: [.fighting, .flying, .poison, .ghost, .steel, .fire, .fairy]),
        .ghost: Matchup(superEffective: [.ghost, .psychic], notVeryEffective: [.dark], noEffect: [.normal]),
        .steel: Matchup(superEffective: [.rock, .ice, .fairy], notVeryEffective: [.steel, .fire, .water, .electric]),
        .fire: Matchup(superEffective: [.bug, .steel, .grass, .ice], notVeryEffective: [.rock, .fire, .water, .dragon]),
        .water: Matchup(superEffective: [.ground, .rock, .fire], notVeryEffective: [.water, .grass, .dragon]),
        .grass: Matchup(superEffective: [.ground, .rock, .water], notVeryEffective: [.flying, .poison, .bug, .steel, .fire, .grass, .dragon]),
        .electric: Matchup(superEffective: [.flying, .water], notVeryEffective: [.grass, .electric, .dragon], noEffect: [.ground]),
        .psychic: Matchup(superEffective: [.fighting, .poison], notVeryEffective: [.steel, .psychic], noEffect: [.dark]),
        .ice: Matchup(superEffective: [.flying, .ground, .grass, .dragon], notVeryEffective: [.steel, .fire, .water, .ice]),
        .dragon: Matchup(superEffective: [.dragon], notVeryEffective: [.steel], noEffect: [.fairy]),
        .dark: Matchup(superEffective: [.ghost, .psychic], notVeryEffective: [.fighting, .dark, .fairy]),
        .fairy: Matchup(superEffective: [.fighting, .dragon, .dark], notVeryEffective: [.poison, .steel, .fire])
    ]
}
