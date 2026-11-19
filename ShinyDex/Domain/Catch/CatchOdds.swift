import Foundation

enum CatchOdds {
    // Chain methods and Let's Go return nil: their odds depend on how the chain went, which isn't recorded.
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

    static func chanceOfFindingSooner(_ caught: Catch) -> Double? {
        guard let odds = odds(for: caught), caught.encounters > 0 else { return nil }
        return Double.getProbability(encounters: caught.encounters, odds: odds)
    }
}
