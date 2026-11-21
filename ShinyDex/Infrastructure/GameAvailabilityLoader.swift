import Foundation

enum GameAvailabilityLoader {
    private struct StoredGame: Decodable {
        let catchable: [Int]
        let tradeOnly: [Int]
        let approximate: Bool
    }

    static func load(from resourceLoader: ResourceLoader) -> GameAvailability {
        guard let data = resourceLoader.loadData(ofResource: "gameAvailability", withExtension: "json"),
              let stored = try? JSONDecoder().decode([String: StoredGame].self, from: data) else {
            return GameAvailability()
        }
        let dataByGame = Dictionary(uniqueKeysWithValues: stored.compactMap { gameName, game in
            Games(rawValue: gameName).map {
                ($0, GameAvailability.GameData(catchable: Set(game.catchable.map { $0 - 1 }), tradeOnly: Set(game.tradeOnly.map { $0 - 1 }), isApproximate: game.approximate))
            }
        })
        return GameAvailability(dataByGame: dataByGame)
    }
}
