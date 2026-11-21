import Foundation

struct ApplyPPPresetCommand {
    let presetId: String
}

final class ApplyPPPresetHandler {
    private let presets: PPPresets
    private let getMoveOptions: GetMoveOptionsHandler
    private let moveRepository: MoveRepository

    init(presets: PPPresets, getMoveOptions: GetMoveOptionsHandler, moveRepository: MoveRepository) {
        self.presets = presets
        self.getMoveOptions = getMoveOptions
        self.moveRepository = moveRepository
    }

    @discardableResult
    func handle(_ command: ApplyPPPresetCommand) -> Bool {
        guard let preset = presets.find(id: command.presetId) else { return false }
        let slots = preset.makeSlots(from: getMoveOptions.handle(GetMoveOptionsQuery()))
        guard !slots.isEmpty else { return false }
        let isPressureActive = moveRepository.getActiveMoves()?.pressureActive ?? false
        moveRepository.save(ActiveMoves(moves: slots.map { $0.activeMove }, pressureActive: isPressureActive))
        return true
    }
}

extension PPPreset {
    func makeSlots(from moveOptions: [MoveOption]) -> [MoveSlot] {
        let optionsByIdentifier = Dictionary(moveOptions.map { ($0.identifier, $0) }, uniquingKeysWith: { first, _ in first })
        return moveIdentifiers.compactMap { identifier in
            optionsByIdentifier[identifier].map { MoveSlot(name: $0.name, maxPP: $0.pp, remainingPP: $0.pp, type: $0.type) }
        }
    }
}
