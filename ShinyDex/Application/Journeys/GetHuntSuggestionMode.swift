import Foundation

struct GetHuntSuggestionModeQuery {}

final class GetHuntSuggestionModeHandler {
    private let keyValueStore: KeyValueStore

    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }

    func handle(_ query: GetHuntSuggestionModeQuery) -> HuntSuggestionMode {
        return keyValueStore.getBool(forKey: HuntSuggestionKeys.usesBestOdds) ? .bestOdds : .fullOdds
    }
}
