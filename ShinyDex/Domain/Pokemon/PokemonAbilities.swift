import Foundation

struct AbilitySet: Equatable {
    let regular: [String]
    let hidden: String?

    var all: [String] {
        return regular + (hidden.map { [$0] } ?? [])
    }
}

struct PokemonAbilities {
    struct Key: Hashable {
        let number: Int
        let formId: String?
    }

    struct GenerationRange: Equatable {
        let fromGeneration: Int
        let abilities: AbilitySet
    }

    fileprivate static let gamesWithoutAbilities: Set<Games> = [.LetsGoPikachu, .LetsGoEevee, .LegendsArceus]
    fileprivate static let firstGenerationWithAbilities = 3

    fileprivate let namesById: [String: String]
    fileprivate let rangesByKey: [Key: [GenerationRange]]

    init(namesById: [String: String] = [:], rangesByKey: [Key: [GenerationRange]] = [:]) {
        self.namesById = namesById
        self.rangesByKey = rangesByKey
    }

    static func hasAbilities(_ game: Games) -> Bool {
        guard let generation = GamesList.games[game]?.generation else { return false }
        return generation >= firstGenerationWithAbilities && !gamesWithoutAbilities.contains(game)
    }

    func findAbilities(of number: Int, formId: String?, in game: Games) -> AbilitySet? {
        guard PokemonAbilities.hasAbilities(game), let generation = GamesList.games[game]?.generation else { return nil }
        let ranges = rangesByKey[Key(number: number, formId: formId)] ?? rangesByKey[Key(number: number, formId: nil)] ?? []
        return ranges.last { $0.fromGeneration <= generation }?.abilities
    }

    func findName(of abilityId: String) -> String {
        return namesById[abilityId] ?? abilityId.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }

    func carryOver(_ abilityId: String?, from source: Key, to target: Key, in game: Games) -> String? {
        guard let abilityId = abilityId,
              let targetAbilities = findAbilities(of: target.number, formId: target.formId, in: game) else { return abilityId }
        if targetAbilities.all.contains(abilityId) {
            return abilityId
        }
        guard let sourceAbilities = findAbilities(of: source.number, formId: source.formId, in: game) else { return nil }
        if sourceAbilities.hidden == abilityId {
            return targetAbilities.hidden
        }
        guard let slot = sourceAbilities.regular.firstIndex(of: abilityId) else { return nil }
        return targetAbilities.regular.indices.contains(slot) ? targetAbilities.regular[slot] : targetAbilities.regular.first
    }
}
