import Foundation

enum PokemonAbilitiesLoader {
    private struct StoredAbilities: Decodable {
        struct Entry: Decodable {
            struct Range: Decodable {
                let from: Int
                let abilities: [String]
                let hidden: String?
            }

            let number: Int
            let form: String?
            let generations: [Range]
        }

        let names: [String: String]
        let pokemon: [Entry]
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonAbilities {
        guard let data = resourceLoader.loadData(ofResource: "abilities", withExtension: "json"),
              let stored = try? JSONDecoder().decode(StoredAbilities.self, from: data) else {
            return PokemonAbilities()
        }
        let rangesByKey = Dictionary(stored.pokemon.map { entry in
            (PokemonAbilities.Key(number: entry.number, formId: entry.form),
             entry.generations.map { PokemonAbilities.GenerationRange(fromGeneration: $0.from, abilities: AbilitySet(regular: $0.abilities, hidden: $0.hidden)) })
        }, uniquingKeysWith: { first, _ in first })
        return PokemonAbilities(namesById: stored.names, rangesByKey: rangesByKey)
    }
}
