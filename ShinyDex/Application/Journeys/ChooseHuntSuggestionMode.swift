import Foundation

struct ChooseHuntSuggestionModeCommand {
    let mode: HuntSuggestionMode
}

final class ChooseHuntSuggestionModeHandler {
    private let keyValueStore: KeyValueStore

    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: ChooseHuntSuggestionModeCommand) {
        keyValueStore.set(command.mode == .bestOdds, forKey: HuntSuggestionKeys.usesBestOdds)
    }
}
