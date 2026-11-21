import Foundation

struct GetPPPresetsQuery {}

struct PPPresetSummary: Equatable {
    let id: String
    let pokemonName: String
    let game: String
    let onlyIn: String?
    let level: Int
    let isRoaming: Bool
    let moveNames: [String]
}

final class GetPPPresetsHandler {
    private let presets: PPPresets
    private let getMoveOptions: GetMoveOptionsHandler

    init(presets: PPPresets, getMoveOptions: GetMoveOptionsHandler) {
        self.presets = presets
        self.getMoveOptions = getMoveOptions
    }

    func handle(_ query: GetPPPresetsQuery) -> [PPPresetSummary] {
        let moveOptions = getMoveOptions.handle(GetMoveOptionsQuery())
        return presets.presets.compactMap { preset in
            let slots = preset.makeSlots(from: moveOptions)
            guard !slots.isEmpty else { return nil }
            return PPPresetSummary(id: preset.id, pokemonName: preset.pokemonName, game: preset.game, onlyIn: preset.onlyIn, level: preset.level,
                                   isRoaming: preset.isRoaming, moveNames: slots.map { $0.name })
        }
    }
}
