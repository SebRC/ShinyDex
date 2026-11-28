import Foundation

enum TradeGroups {
    static let all: [[Games]] = [
        [.Red, .Blue, .Yellow, .Gold, .Silver, .Crystal],
        [.Ruby, .Sapphire, .Emerald, .FireRed, .LeafGreen],
        [.Diamond, .Pearl, .Platinum, .Heartgold, .SoulSilver],
        [.Black, .White, .Black2, .White2],
        [.X, .Y, .OmegaRuby, .AlphaSapphire],
        [.Sun, .Moon, .UltraSun, .UltraMoon],
        [.LetsGoPikachu, .LetsGoEevee],
        [.Sword, .Shield],
        [.BrilliantDiamond, .ShiningPearl],
        [.LegendsArceus],
        [.Scarlet, .Violet]
    ]

    static func findPartners(of game: Games) -> [Games] {
        let group = all.first { $0.contains(game) } ?? [game]
        return [game] + group.filter { $0 != game }
    }

    static func findTransferSources(for game: Games) -> [Games] {
        guard let generation = GamesList.games[game]?.generation else { return [] }
        let partners = findPartners(of: game)
        return Games.allCases
            .filter { !partners.contains($0) && (GamesList.games[$0]?.generation ?? .max) < generation }
            .sorted { (GamesList.games[$0]?.generation ?? 0) > (GamesList.games[$1]?.generation ?? 0) }
    }

    static func canObtain(_ number: Int, for game: Games) -> Bool {
        guard let introduced = GameAvailability.findIntroducedGeneration(of: number), let generation = GamesList.games[game]?.generation else { return true }
        return introduced <= generation
    }
}
