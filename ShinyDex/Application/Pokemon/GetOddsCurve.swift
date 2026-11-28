import Foundation

struct GetOddsCurveQuery {
    let number: Int
}

struct OddsCurvePoint: Equatable {
    let encounters: Int
    let chance: Double
}

struct OddsCurveSummary: Equatable {
    let shinyOdds: Int
    let usesChain: Bool
    let current: OddsCurvePoint
    let milestones: [OddsCurvePoint]
    let points: [OddsCurvePoint]
}

final class GetOddsCurveHandler {
    private let pokemonRepository: PokemonRepository
    private let odds: OddsService
    private let probability: ProbabilityService

    init(pokemonRepository: PokemonRepository, odds: OddsService, probability: ProbabilityService) {
        self.pokemonRepository = pokemonRepository
        self.odds = odds
        self.probability = probability
    }

    func handle(_ query: GetOddsCurveQuery) -> OddsCurveSummary? {
        guard let pokemon = pokemonRepository.get(number: query.number) else { return nil }
        let configuration = pokemon.huntConfiguration
        let curve = OddsCurve(encounters: pokemon.encounters, chain: pokemon.chain, configuration: configuration,
                              calculator: ShinyChanceCalculator(odds: odds, probability: probability))
        return OddsCurveSummary(
            shinyOdds: odds.getShinyOdds(configuration: configuration, chain: pokemon.chain),
            usesChain: configuration.usesChain,
            current: OddsCurvePoint(encounters: curve.current.encounters, chance: curve.current.chance),
            milestones: curve.milestones.map { OddsCurvePoint(encounters: $0.encounters, chance: $0.chance) },
            points: curve.points.map { OddsCurvePoint(encounters: $0.encounters, chance: $0.chance) })
    }
}
