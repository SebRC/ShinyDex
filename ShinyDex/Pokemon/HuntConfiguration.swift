import Foundation

struct HuntConfiguration: Equatable {
    var game: Games
    var generation: Int
    var huntMethod: HuntMethod
    var isShinyCharmActive: Bool

    // Choosing a game also sets its generation and drops a method or Shiny Charm the game doesn't have.
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

    // The Shiny Charm can't be active in a game without one. A method the game lacks is kept, as it always has been,
    // because the settings screen only disables its switch.
    func normalized() -> HuntConfiguration {
        var configuration = self
        if !(GamesList.games[game]?.isShinyCharmAvailable ?? false) {
            configuration.isShinyCharmActive = false
        }
        return configuration
    }

    // Encounters that build up a chain or combo before boosted odds apply.
    var chainThreshold: Int {
        if huntMethod == .SosChaining || huntMethod == .Lure || generation == 0 {
            return 30
        }
        switch huntMethod {
        case .ChainFishing: return 20
        case .Pokeradar: return 40
        case .DexNav: return 999
        default: return 0
        }
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
