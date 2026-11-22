import Foundation

enum PokemonLearnsetsLoader {
    private struct StoredLearnsets: Decodable {
        struct Entry: Decodable {
            let number: Int
            let form: String?
            let learnsets: [Int]
        }

        let games: [String]
        let moves: [String: StoredMove]
        let learnsets: [[[Int]]]
        let pokemon: [Entry]
    }

    private struct StoredMove: Decodable {
        let name: String
        let type: String
        let pp: Int

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            name = try container.decode(String.self)
            type = try container.decode(String.self)
            pp = try container.decode(Int.self)
        }
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonLearnsets {
        guard let data = resourceLoader.loadData(ofResource: "learnsets", withExtension: "json"),
              let stored = try? JSONDecoder().decode(StoredLearnsets.self, from: data) else {
            return PokemonLearnsets()
        }
        let games = stored.games.map { Games(rawValue: $0) }
        let movesById = Dictionary(stored.moves.compactMap { key, move in
            Int(key).map { ($0, LearnableMove(id: $0, name: move.name, type: move.type.capitalized, pp: move.pp)) }
        }, uniquingKeysWith: { first, _ in first })
        let indexesByKey = Dictionary(stored.pokemon.map { entry -> (PokemonLearnsets.Key, [Games: Int]) in
            var indexes = [Games: Int]()
            for (position, index) in entry.learnsets.enumerated() where index >= 0 && games.indices.contains(position) {
                if let game = games[position] {
                    indexes[game] = index
                }
            }
            return (PokemonLearnsets.Key(number: entry.number, formId: entry.form), indexes)
        }, uniquingKeysWith: { first, _ in first })
        return PokemonLearnsets(movesById: movesById, learnsets: stored.learnsets, learnsetIndexesByKey: indexesByKey)
    }
}
