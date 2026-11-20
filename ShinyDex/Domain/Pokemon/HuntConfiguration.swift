import Foundation

struct HuntConfiguration: Equatable {
    var game: Games
    var generation: Int
    var huntMethod: HuntMethod
    var isShinyCharmActive: Bool

    func selecting(_ game: Games) -> HuntConfiguration {
        var configuration = self
        configuration.game = game
        if let details = GamesList.games[game] {
            configuration.generation = details.generation
        }
        if let details = GamesList.games[game], !details.availableMethods.contains(huntMethod) {
            configuration.huntMethod = .Encounters
        }
        return configuration.normalized()
    }

    // A method the game lacks is deliberately kept: the settings screen only disables its switch.
    func normalized() -> HuntConfiguration {
        var configuration = self
        if !(GamesList.games[game]?.isShinyCharmAvailable ?? false) {
            configuration.isShinyCharmActive = false
        }
        return configuration
    }

    var isLetsGo: Bool {
        return game == .LetsGoPikachu || game == .LetsGoEevee || generation == 0
    }

    var usesChain: Bool {
        return isLetsGo || [.Pokeradar, .ChainFishing, .SosChaining, .DexNav, .Lure].contains(huntMethod)
    }

    var chainForBestOdds: Int {
        if isLetsGo || huntMethod == .Lure || huntMethod == .SosChaining {
            return 31
        }
        switch huntMethod {
        case .ChainFishing: return 20
        case .Pokeradar: return 40
        case .DexNav: return 999
        default: return 0
        }
    }

    func makeChainFromLegacyEncounters(_ encounters: Int) -> Int {
        return usesChain ? min(max(encounters, 0), chainForBestOdds) : 0
    }
}

extension Pokemon {
    var huntConfiguration: HuntConfiguration {
        get {
            return HuntConfiguration(game: game, generation: generation, huntMethod: huntMethod, isShinyCharmActive: isShinyCharmActive)
        }
        set {
            game = newValue.game
            generation = newValue.generation
            huntMethod = newValue.huntMethod
            isShinyCharmActive = newValue.isShinyCharmActive
        }
    }
}
