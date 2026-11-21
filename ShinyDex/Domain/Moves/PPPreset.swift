import Foundation

struct PPPreset: Equatable {
    let id: String
    let pokemonName: String
    let game: String
    let onlyIn: String?
    let level: Int
    let isRoaming: Bool
    let moveIdentifiers: [String]
}

struct PPPresets {
    let presets: [PPPreset]

    init(presets: [PPPreset] = []) {
        self.presets = presets
    }

    func find(id: String) -> PPPreset? {
        return presets.first { $0.id == id }
    }
}
