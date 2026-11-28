import Foundation

enum MoveTypingLoader {
    private struct Entry: Decodable {
        let id: Int
        let type_id: Int
    }

    static func load(from resourceLoader: ResourceLoader) -> MoveTyping {
        guard let data = resourceLoader.loadData(ofResource: "moves", withExtension: "json"),
              let entries = try? JSONDecoder().decode([Entry].self, from: data) else {
            return MoveTyping()
        }
        let typesById = Dictionary(entries.compactMap { entry in
            PokemonType(rawValue: entry.type_id).map { (entry.id, $0) }
        }, uniquingKeysWith: { first, _ in first })
        return MoveTyping(typesById: typesById)
    }
}
