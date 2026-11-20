import Foundation

struct HuntCounterText: Equatable {
    struct Line: Equatable {
        let label: String
        let value: Int
    }

    let primary: Line
    let secondary: Line?

    init(primary: Line, secondary: Line?) {
        self.primary = primary
        self.secondary = secondary
    }

    init(pokemon: PokemonDetails) {
        let settings = pokemon.settings
        if pokemon.usesChain {
            primary = Line(label: HuntCounterText.makeChainLabel(for: settings), value: pokemon.chain)
            secondary = Line(label: settings.huntMethod == .Pokeradar ? "Patches" : "Encounters", value: pokemon.encounters)
        }
        else {
            let isBreeding = settings.huntMethod == .Masuda || settings.huntMethod == .Gen2Breeding
            primary = Line(label: isBreeding ? "Eggs" : "Encounters", value: pokemon.encounters)
            secondary = nil
        }
    }

    static func makeChainLabel(for settings: HuntSettings) -> String {
        if settings.game == .LetsGoPikachu || settings.game == .LetsGoEevee || settings.huntMethod == .Lure {
            return "Catch combo"
        }
        return settings.huntMethod == .DexNav ? "Search level" : "Chain"
    }
}
