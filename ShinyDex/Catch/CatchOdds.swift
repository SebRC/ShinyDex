import Foundation

enum CatchOdds {
    // Fixed odds for the catch's game and method. Chain methods and Let's Go depend on how the chain went, which isn't recorded.
    static func odds(for caught: Catch) -> Int? {
        let generation = GamesList.games[caught.game]?.generation ?? 0
        let charm = caught.isShinyCharmActive
        if caught.game == .LetsGoPikachu || caught.game == .LetsGoEevee {
            return nil
        }
        switch caught.huntMethod {
        case .Gen2Breeding:
            return Gen2BreedingOddsService().getOdds()
        case .Masuda:
            return MasudaOddsService().getOdds(generation: generation, isCharmActive: charm)
        case .FriendSafari:
            return FriendSafariOddsService().getOdds(isShinyCharmActive: charm)
        case .Encounters:
            if generation < 5 { return 8192 }
            if generation == 5 { return charm ? 2731 : 8192 }
            return charm ? 1365 : 4096
        default:
            return nil
        }
    }

    // The chance, as a percentage, that a hunt at these odds would have found a shiny within this catch's encounters.
    static func chanceOfFindingSooner(_ caught: Catch) -> Double? {
        guard let odds = odds(for: caught), caught.encounters > 0 else { return nil }
        return Double.getProbability(encounters: caught.encounters, odds: odds)
    }
}
