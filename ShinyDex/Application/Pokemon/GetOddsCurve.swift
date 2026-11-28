import Foundation

struct GetOddsCurveQuery {
    let number: Int
}

struct OddsCurvePoint: Equatable {
    let encounters: Int
    let chance: Double
}

struct OddsCurveMilestone: Equatable {
    let encounters: Int
    let chance: Double
    let daysToReach: Int?
}

struct OddsCurveSummary: Equatable {
    let shinyOdds: Int
    let usesChain: Bool
    let current: OddsCurvePoint
    let milestones: [OddsCurveMilestone]
    let points: [OddsCurvePoint]
    var pace: HuntForecast? = nil
}

final class GetOddsCurveHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService
    private let probability: ProbabilityService
    private let getHuntForecast: GetHuntForecastHandler

    init(pokemonRepository: PokemonRepository, odds: OddsService, probability: ProbabilityService, getHuntForecast: GetHuntForecastHandler) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
        self.probability = probability
        self.getHuntForecast = getHuntForecast
    }

    func handle(_ query: GetOddsCurveQuery) -> OddsCurveSummary? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        let configuration = pokemon.huntConfiguration
        let curve = OddsCurve(encounters: pokemon.encounters, chain: pokemon.chain, configuration: configuration,
                              calculator: ShinyChanceCalculator(odds: odds, probability: probability))
        let pace = getHuntForecast.findPace(of: query.number)
        return OddsCurveSummary(
            shinyOdds: odds.getShinyOdds(configuration: configuration, chain: pokemon.chain),
            usesChain: configuration.usesChain,
            current: OddsCurvePoint(encounters: curve.current.encounters, chance: curve.current.chance),
            milestones: curve.milestones.map { milestone in
                return OddsCurveMilestone(encounters: milestone.encounters, chance: milestone.chance,
                                          daysToReach: pace?.estimateDays(toCover: milestone.encounters - curve.current.encounters))
            },
            points: curve.points.map { OddsCurvePoint(encounters: $0.encounters, chance: $0.chance) },
            pace: getHuntForecast.handle(GetHuntForecastQuery(number: query.number)))
    }
}
