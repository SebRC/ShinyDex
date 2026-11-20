import Foundation

struct HuntSettings: Equatable {
    var game: Games
    var generation: Int
    var huntMethod: HuntMethod
    var isShinyCharmActive: Bool
}

struct PokemonSummary: Equatable {
    let number: Int
    let name: String
    let caughtBall: String
    let isBeingHunted: Bool
    let encounters: Int
}

struct FormChoice: Equatable {
    let id: String
    let name: String
}

struct FormChoices: Equatable {
    static let standardName = "Standard"

    let defaultName: String
    let forms: [FormChoice]

    init?(_ speciesForms: SpeciesForms?) {
        guard let speciesForms = speciesForms, !speciesForms.alternates.isEmpty else { return nil }
        defaultName = speciesForms.defaultName ?? FormChoices.standardName
        forms = speciesForms.alternates.map { FormChoice(id: $0.id, name: $0.name) }
    }

    func findName(of formId: String?) -> String {
        return forms.first { $0.id == formId }?.name ?? defaultName
    }
}

struct PokemonDetails: Equatable {
    let number: Int
    let name: String
    let encounters: Int
    let increment: Int
    let settings: HuntSettings
    let shinyOdds: Int
    let chain: Int
    let usesChain: Bool
    let probability: Double
    let caughtBall: String
    let catchCount: Int
    let isBeingHunted: Bool
}

extension HuntSettings {
    init(_ configuration: HuntConfiguration) {
        self.init(game: configuration.game, generation: configuration.generation, huntMethod: configuration.huntMethod, isShinyCharmActive: configuration.isShinyCharmActive)
    }

    var configuration: HuntConfiguration {
        return HuntConfiguration(game: game, generation: generation, huntMethod: huntMethod, isShinyCharmActive: isShinyCharmActive)
    }
}

extension PokemonSummary {
    init(_ pokemon: Pokemon) {
        self.init(number: pokemon.number, name: pokemon.name, caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, encounters: pokemon.encounters)
    }
}

struct PokemonDetailsMapper {
    let odds: OddsService
    let probability: ProbabilityService

    func makeDetails(of pokemon: Pokemon, catchCount: Int) -> PokemonDetails {
        let configuration = pokemon.huntConfiguration
        let shinyOdds = odds.getShinyOdds(configuration: configuration, chain: pokemon.chain)
        let calculator = ShinyChanceCalculator(odds: odds, probability: probability)
        return PokemonDetails(
            number: pokemon.number,
            name: pokemon.name,
            encounters: pokemon.encounters,
            increment: pokemon.increment,
            settings: HuntSettings(configuration),
            shinyOdds: shinyOdds,
            chain: pokemon.chain,
            usesChain: configuration.usesChain,
            probability: calculator.calculateChance(encounters: pokemon.encounters, chain: pokemon.chain, configuration: configuration),
            caughtBall: pokemon.caughtBall,
            catchCount: catchCount,
            isBeingHunted: pokemon.isBeingHunted)
    }
}
