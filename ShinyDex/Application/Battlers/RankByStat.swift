import Foundation

struct RankByStatQuery {
    let stat: Stat
    let level: BattleLevel
    var showsBestOfEachSpecies = false
}

final class RankByStatHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let baseStats: PokemonBaseStats

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), baseStats: PokemonBaseStats = PokemonBaseStats()) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.baseStats = baseStats
    }

    func handle(_ query: RankByStatQuery) -> StatRanking {
        let namesByNumber = Dictionary(pokemonRepository.getAll().map { ($0.number, $0.name) }, uniquingKeysWith: { first, _ in first })
        let candidates = catchRepository.getAll().filter { !$0.isFailed && namesByNumber[$0.number] != nil && IndividualValues.isUsed(in: $0.game) && !$0.ivs.isEmpty }
        let leaderboard = StatLeaderboard(catches: candidates, stat: query.stat, level: query.level, baseStats: baseStats)
        var seenNumbers = Set<Int>()
        let entries = leaderboard.entries.filter { !query.showsBestOfEachSpecies || seenNumbers.insert($0.caught.number).inserted }
        return StatRanking(
            leaders: entries.map { entry in
                StatLeader(id: CatchID(rawValue: entry.caught.id),
                           number: entry.caught.number,
                           pokemonName: namesByNumber[entry.caught.number]!,
                           nickname: entry.caught.nickname,
                           formId: entry.caught.formId,
                           formName: forms.findForm(entry.caught.formId, of: entry.caught.number)?.name,
                           nature: entry.caught.nature,
                           iv: entry.iv,
                           ev: entry.caught.evs[query.stat],
                           value: entry.value,
                           trainedValue: entry.trainedValue,
                           trainedRank: query.showsBestOfEachSpecies ? nil : entry.trainedRank)
            },
            catchesWithoutIV: leaderboard.catchesWithoutIV)
    }
}
