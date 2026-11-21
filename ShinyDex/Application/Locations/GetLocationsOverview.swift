import Foundation

struct GetLocationsOverviewQuery {
    let number: Int
}

struct LocationsOverview: Equatable {
    struct Technique: Equatable {
        enum Kind: Equatable {
            case repel
            case repelWithPressure
            case keenEye
            case staticAbility
            case magnetPull
        }

        let kind: Kind
        let ratePercent: Int
        var encounterPercent: Int? = nil
    }

    struct BestPlace: Equatable {
        let area: String
        let method: String
        let ratePercent: Int
        let isOneTime: Bool
        let technique: Technique?

        var bestRatePercent: Int {
            return isOneTime ? 0 : max(ratePercent, technique?.ratePercent ?? 0)
        }
    }

    struct GameSummary: Equatable {
        let game: Games
        let generation: Int
        let availability: GameChoice.Availability
        let isApproximate: Bool
        let hasLocationData: Bool
        let bestPlace: BestPlace?
        let guidance: PokemonLocationsResult.Guidance
    }

    let pokemonName: String
    let huntingGame: Games
    let games: [GameSummary]

    var huntingGameSummary: GameSummary? {
        return games.first { $0.game == huntingGame && $0.availability == .catchable }
    }

    var bestGames: [GameSummary] {
        return games.enumerated()
            .filter { $0.element.availability == .catchable && $0.element.bestPlace != nil }
            .sorted { lhs, rhs in
                let lhsIsRepeatable = lhs.element.bestPlace?.isOneTime == false, rhsIsRepeatable = rhs.element.bestPlace?.isOneTime == false
                if lhsIsRepeatable != rhsIsRepeatable { return lhsIsRepeatable }
                let lhsRate = lhs.element.bestPlace?.bestRatePercent ?? 0, rhsRate = rhs.element.bestPlace?.bestRatePercent ?? 0
                return lhsRate != rhsRate ? lhsRate > rhsRate : lhs.offset < rhs.offset
            }
            .map { $0.element }
    }
}

final class GetLocationsOverviewHandler {
    private let pokemonRepository: PokemonRepository
    private let getPokemonLocations: GetPokemonLocationsHandler
    private let getGameChoices: GetGameChoicesHandler

    init(pokemonRepository: PokemonRepository, getPokemonLocations: GetPokemonLocationsHandler, getGameChoices: GetGameChoicesHandler) {
        self.pokemonRepository = pokemonRepository
        self.getPokemonLocations = getPokemonLocations
        self.getGameChoices = getGameChoices
    }

    func handle(_ query: GetLocationsOverviewQuery) -> LocationsOverview? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        let huntingGame = pokemon.huntConfiguration.game
        let summaries = getGameChoices.handle(GetGameChoicesQuery(number: query.number, keeping: huntingGame)).compactMap { choice -> LocationsOverview.GameSummary? in
            guard let result = getPokemonLocations.handle(GetPokemonLocationsQuery(number: query.number, game: choice.game)) else { return nil }
            return LocationsOverview.GameSummary(game: choice.game, generation: GamesList.games[choice.game]?.generation ?? 0, availability: choice.availability,
                                                 isApproximate: choice.isApproximate, hasLocationData: result.hasLocationData,
                                                 bestPlace: GetLocationsOverviewHandler.findBestPlace(in: result), guidance: result.guidance)
        }
        return LocationsOverview(pokemonName: pokemon.name, huntingGame: huntingGame, games: summaries)
    }

    private static func findBestPlace(in result: PokemonLocationsResult) -> LocationsOverview.BestPlace? {
        let candidates = result.places.flatMap { place in
            place.encounters.filter { !$0.isShinyLocked }.map { encounter in
                LocationsOverview.BestPlace(area: place.area, method: encounter.method, ratePercent: encounter.ratePercent, isOneTime: encounter.isOneTime,
                                            technique: findBestTechnique(for: encounter))
            }
        }
        return candidates.max { lhs, rhs in
            lhs.bestRatePercent != rhs.bestRatePercent ? lhs.bestRatePercent < rhs.bestRatePercent : lhs.ratePercent < rhs.ratePercent
        }
    }

    private static func findBestTechnique(for encounter: PokemonLocationsResult.Encounter) -> LocationsOverview.Technique? {
        var techniques = [LocationsOverview.Technique]()
        if let repel = encounter.repelTrick {
            techniques.append(LocationsOverview.Technique(kind: .repel, ratePercent: repel.ratePercent, encounterPercent: repel.encounterPercent))
            if let withPressure = repel.withPressureRatePercent {
                techniques.append(LocationsOverview.Technique(kind: .repelWithPressure, ratePercent: withPressure, encounterPercent: repel.withPressureEncounterPercent))
            }
        }
        if let keenEye = encounter.keenEyeBoost {
            techniques.append(LocationsOverview.Technique(kind: .keenEye, ratePercent: keenEye.ratePercent))
        }
        for boost in encounter.abilityBoosts {
            techniques.append(LocationsOverview.Technique(kind: boost.ability == .staticAbility ? .staticAbility : .magnetPull, ratePercent: boost.ratePercent))
        }
        return techniques
            .filter { $0.ratePercent >= encounter.ratePercent + 5 || Double($0.ratePercent) >= Double(encounter.ratePercent) * 1.5 }
            .max { $0.ratePercent < $1.ratePercent }
    }
}
