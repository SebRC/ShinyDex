import Foundation

struct GetPokemonLocationsQuery {
    let number: Int
    let game: Games
}

struct PokemonLocationsResult: Equatable {
    struct Place: Equatable {
        let area: String
        let encounters: [Encounter]

        var bestRatePercent: Int {
            return encounters.filter { !$0.isShinyLocked }.map { $0.isOneTime ? 100 : $0.ratePercent }.max() ?? -1
        }
    }

    struct Encounter: Equatable {
        enum Ability: Equatable {
            case staticAbility
            case magnetPull
        }

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
            let ability: Ability
            let ratePercent: Int
        }

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

        var huntingRatePercent: Int {
            if isShinyLocked { return -1 }
            return isOneTime ? 100 : ratePercent
        }

        var isOneTime: Bool {
            return ratePercent == 0
        }
    }

    enum Guidance: Equatable {
        case none
        case evolveFrom(NamedPokemon)
        case breedFrom(NamedPokemon)
        case shinyLocked
        case tradeOnly
        case unavailable
    }

    let pokemonName: String
    let game: Games
    let availability: GameChoice.Availability
    let isApproximate: Bool
    let hasLocationData: Bool
    let places: [Place]
    let guidance: Guidance
}

final class GetPokemonLocationsHandler {
    private let pokemonRepository: PokemonRepository
    private let locations: PokemonLocations
    private let availability: GameAvailability
    private let evolutions: Evolutions

    init(pokemonRepository: PokemonRepository, locations: PokemonLocations, availability: GameAvailability, evolutions: Evolutions) {
        self.pokemonRepository = pokemonRepository
        self.locations = locations
        self.availability = availability
        self.evolutions = evolutions
    }

    func handle(_ query: GetPokemonLocationsQuery) -> PokemonLocationsResult? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        let found = locations.findLocations(of: query.number, in: query.game)
        let gameAvailability = GetPokemonLocationsHandler.map(availability.findAvailability(of: query.number, in: query.game))
        return PokemonLocationsResult(pokemonName: pokemon.name,
                                      game: query.game,
                                      availability: gameAvailability,
                                      isApproximate: availability.isApproximate(query.game),
                                      hasLocationData: locations.hasData(for: query.game),
                                      places: GetPokemonLocationsHandler.groupByArea(found),
                                      guidance: found.isEmpty ? findGuidance(for: query.number, in: query.game, availability: gameAvailability) : .none)
    }

    private func findGuidance(for number: Int, in game: Games, availability: GameChoice.Availability) -> PokemonLocationsResult.Guidance {
        switch availability {
        case .unavailable:
            return .unavailable
        case .tradeOnly:
            return .tradeOnly
        case .shinyLocked:
            return .shinyLocked
        case .catchable:
            if let ancestor = findAncestors(of: number).first(where: { !locations.findLocations(of: $0, in: game).isEmpty }), let named = makeNamed(ancestor) {
                return .evolveFrom(named)
            }
            if let descendant = findDescendants(of: number).first(where: { !locations.findLocations(of: $0, in: game).isEmpty }), let named = makeNamed(descendant) {
                return .breedFrom(named)
            }
            return .none
        }
    }

    private func findAncestors(of number: Int) -> [Int] {
        var ancestors = [Int]()
        var current = number
        while let parent = evolutions.getParent(of: current), !ancestors.contains(parent) {
            ancestors.append(parent)
            current = parent
        }
        return ancestors
    }

    private func findDescendants(of number: Int) -> [Int] {
        return evolutions.getLine(of: number).filter { $0 != number && findAncestors(of: $0).contains(number) }
    }

    private func makeNamed(_ number: Int) -> NamedPokemon? {
        return pokemonRepository.get(number: number).map { NamedPokemon(number: $0.number, name: $0.name) }
    }

    private static func groupByArea(_ found: [EncounterLocation]) -> [PokemonLocationsResult.Place] {
        return Dictionary(grouping: found) { $0.area }
            .map { area, locations in
                PokemonLocationsResult.Place(area: area, encounters: locations.map(makeEncounter).sorted { $0.huntingRatePercent > $1.huntingRatePercent })
            }
            .sorted {
                $0.bestRatePercent != $1.bestRatePercent ? $0.bestRatePercent > $1.bestRatePercent : $0.area.localizedStandardCompare($1.area) == .orderedAscending
            }
    }

    private static func makeEncounter(_ location: EncounterLocation) -> PokemonLocationsResult.Encounter {
        return PokemonLocationsResult.Encounter(
            method: location.method, minimumLevel: location.minimumLevel, maximumLevel: location.maximumLevel, ratePercent: location.ratePercent,
            condition: location.condition,
            repelTrick: location.repelTrick.map {
                PokemonLocationsResult.Encounter.RepelTrick(leadLevel: $0.leadLevel, ratePercent: $0.ratePercent, withPressureRatePercent: $0.withPressureRatePercent,
                                                            encounterPercent: $0.encounterPercent, withPressureEncounterPercent: $0.withPressureEncounterPercent)
            },
            abilityBoosts: location.abilityBoosts.map { boost in
                PokemonLocationsResult.Encounter.AbilityBoost(ability: boost.ability == .staticAbility ? .staticAbility : .magnetPull, ratePercent: boost.ratePercent)
            },
            keenEyeBoost: location.keenEyeBoost.map { PokemonLocationsResult.Encounter.KeenEyeBoost(leadLevel: $0.leadLevel, ratePercent: $0.ratePercent) },
            isShinyLocked: location.isShinyLocked, isSpedUpByAbilities: location.isSpedUpByAbilities)
    }

    private static func map(_ availability: PokemonAvailability) -> GameChoice.Availability {
        switch availability {
        case .catchable: return .catchable
        case .shinyLocked: return .shinyLocked
        case .tradeOnly: return .tradeOnly
        case .unavailable: return .unavailable
        }
    }
}
