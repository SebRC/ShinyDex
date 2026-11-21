import Foundation

enum EncounterAbility: Equatable {
    case staticAbility
    case magnetPull
}

struct EncounterLocation: Equatable {
    struct RepelTrick: Equatable {
        let leadLevel: Int
        let ratePercent: Int
        var withPressureRatePercent: Int? = nil
        var encounterPercent = 100
        var withPressureEncounterPercent: Int? = nil
    }

    struct KeenEyeBoost: Equatable {
        let leadLevel: Int
        let ratePercent: Int
    }

    struct AbilityBoost: Equatable {
        let ability: EncounterAbility
        let ratePercent: Int
    }

    let area: String
    let method: String
    let minimumLevel: Int
    let maximumLevel: Int
    let ratePercent: Int
    let condition: String?
    var repelTrick: RepelTrick? = nil
    var abilityBoosts: [AbilityBoost] = []
    var keenEyeBoost: KeenEyeBoost? = nil
    var isShinyLocked = false
    var isSpedUpByAbilities = false
}

struct PokemonLocations {
    fileprivate let locationsByGame: [Games: [Int: [EncounterLocation]]]

    init(locationsByGame: [Games: [Int: [EncounterLocation]]] = [:]) {
        self.locationsByGame = locationsByGame
    }

    func hasData(for game: Games) -> Bool {
        return locationsByGame[game] != nil
    }

    func findLocations(of number: Int, in game: Games) -> [EncounterLocation] {
        return locationsByGame[game]?[number] ?? []
    }
}
