import Foundation

enum PPPresetsLoader {
    private struct StoredPreset: Decodable {
        let id: String
        let game: String
        let onlyIn: String?
        let pokemon: String
        let level: Int
        let roaming: Bool
        let moves: [String]
    }

    static func load(from resourceLoader: ResourceLoader) -> PPPresets {
        guard let data = resourceLoader.loadData(ofResource: "ppPresets", withExtension: "json"),
              let stored = try? JSONDecoder().decode([StoredPreset].self, from: data) else {
            return PPPresets()
        }
        return PPPresets(presets: stored.map {
            PPPreset(id: $0.id, pokemonName: $0.pokemon, game: $0.game, onlyIn: $0.onlyIn, level: $0.level, isRoaming: $0.roaming, moveIdentifiers: $0.moves)
        })
    }
}
