import Foundation

enum PokemonAvailability: Equatable {
    case catchable
    case shinyLocked
    case tradeOnly
    case unavailable
}

struct GameAvailability {
    struct GameData: Equatable {
        let catchable: Set<Int>
        var shinyLocked: Set<Int> = []
        let tradeOnly: Set<Int>
        let isApproximate: Bool
    }

    fileprivate let dataByGame: [Games: GameData]

    init(dataByGame: [Games: GameData] = [:]) {
        self.dataByGame = dataByGame
    }

    static func findIntroducedGeneration(of number: Int) -> Int? {
        guard let region = PokedexRegions.all.first(where: { PokedexRegions.getNumbers(inRegion: $0)?.contains(number) == true }) else { return nil }
        return PokedexRegions.findGeneration(ofRegion: region)
    }

    func findAvailability(of number: Int, in game: Games) -> PokemonAvailability {
        guard isReleased(number, in: game) else { return .unavailable }
        guard let data = dataByGame[game] else { return .catchable }
        if data.catchable.contains(number) { return .catchable }
        if data.shinyLocked.contains(number) { return .shinyLocked }
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
