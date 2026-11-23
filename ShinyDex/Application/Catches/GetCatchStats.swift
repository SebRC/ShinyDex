import Foundation

struct GetCatchStatsQuery {
    let catchId: CatchID
}

struct CatchStatLine: Equatable {
    let stat: Stat
    let base: Int?
    let iv: Int?
    let ev: Int
    let value: Int?
}

struct CatchStatSheet: Equatable {
    let pokemonName: String
    let level: Int
    let nature: Nature?
    let ivs: IndividualValues
    let evs: EffortValues
    let lines: [CatchStatLine]
}

final class GetCatchStatsHandler {
    static let defaultLevel = 50

    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let baseStats: PokemonBaseStats

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, baseStats: PokemonBaseStats = PokemonBaseStats()) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.baseStats = baseStats
    }

    func handle(_ query: GetCatchStatsQuery) -> CatchStatSheet? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue),
              let pokemon = pokemonRepository.get(number: caught.number) else { return nil }
        let level = caught.level ?? GetCatchStatsHandler.defaultLevel
        let base = baseStats.findStats(of: caught.number, formId: caught.formId)
        let values = base.map {
            StatCalculator.calculateStats(of: caught.number, base: $0, ivs: caught.ivs, evs: caught.evs, nature: caught.nature, level: level)
        } ?? Array(repeating: nil, count: Stat.allCases.count)
        let lines = Stat.allCases.map { stat in
            CatchStatLine(stat: stat, base: base?[stat], iv: caught.ivs[stat], ev: caught.evs[stat], value: values[stat.rawValue])
        }
        return CatchStatSheet(pokemonName: pokemon.name, level: level, nature: caught.nature, ivs: caught.ivs, evs: caught.evs, lines: lines)
    }
}
