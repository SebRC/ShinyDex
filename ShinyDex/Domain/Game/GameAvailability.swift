import Foundation

enum PokemonAvailability: Equatable {
    case catchable
    case tradeOnly
    case unavailable
}

struct GameAvailability {
    struct GameData: Equatable {
        let catchable: Set<Int>
        let tradeOnly: Set<Int>
        let isApproximate: Bool
    }

    fileprivate let dataByGame: [Games: GameData]

    init(dataByGame: [Games: GameData] = [:]) {
        self.dataByGame = dataByGame
    }

    static func findIntroducedGeneration(of number: Int) -> Int? {
        guard let region = (0...9).first(where: { PokedexRegions.getNumbers(inRegion: $0)?.contains(number) == true }) else { return nil }
        return region < 8 ? region + 1 : region
    }

    func findAvailability(of number: Int, in game: Games) -> PokemonAvailability {
        guard isReleased(number, in: game) else { return .unavailable }
        guard let data = dataByGame[game] else { return .catchable }
        if data.catchable.contains(number) { return .catchable }
        return data.tradeOnly.contains(number) ? .tradeOnly : .unavailable
    }

    func isApproximate(_ game: Games) -> Bool {
        return dataByGame[game]?.isApproximate ?? false
    }

    fileprivate func isReleased(_ number: Int, in game: Games) -> Bool {
        guard let introduced = GameAvailability.findIntroducedGeneration(of: number), let generation = GamesList.games[game]?.generation else { return true }
        return generation >= introduced
    }
}
