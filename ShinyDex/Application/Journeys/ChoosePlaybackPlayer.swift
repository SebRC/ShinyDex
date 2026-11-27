import Foundation

struct ChoosePlaybackPlayerCommand {
    let isFemale: Bool
}

final class ChoosePlaybackPlayerHandler {
    private let keyValueStore: KeyValueStore

    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: ChoosePlaybackPlayerCommand) {
        keyValueStore.set(command.isFemale, forKey: JourneyPlaybackKeys.isPlayerFemale)
    }
}
