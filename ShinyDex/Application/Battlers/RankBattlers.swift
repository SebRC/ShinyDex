import Foundation

struct RankBattlersQuery {
    let ranking: BattlerRanking
    let level: BattleLevel
    let showsBestOfEachSpecies: Bool
    var countsUnusedStatFully = false
}

struct GetBattlerQuery {
    let catchId: CatchID
    var level = BattleLevel.fifty
}

final class RankBattlersHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let baseStats: PokemonBaseStats
    private let moveCategories: MoveCategories
    private let abilities: PokemonAbilities

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), baseStats: PokemonBaseStats = PokemonBaseStats(), moveCategories: MoveCategories = MoveCategories(), abilities: PokemonAbilities = PokemonAbilities()) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.baseStats = baseStats
        self.moveCategories = moveCategories
        self.abilities = abilities
    }

    func handle(_ query: RankBattlersQuery) -> BattlerRankings {
        let namesByNumber = Dictionary(pokemonRepository.getAll().map { ($0.number, $0.name) }, uniquingKeysWith: { first, _ in first })
        let kept = catchRepository.getAll().filter { !$0.isFailed && namesByNumber[$0.number] != nil }
        let olderGeneration = kept.filter(RankBattlersHandler.usesDeterminantValues)
        let modern = kept.filter { !RankBattlersHandler.usesDeterminantValues($0) }
        let withIVs = modern.filter { !$0.ivs.isEmpty }

        let ranked = withIVs
            .map { makeSummary(of: $0, name: namesByNumber[$0.number]!, level: query.level, countsUnusedStatFully: query.countsUnusedStatFully) }
            .sorted { RankBattlersHandler.ranks($0, above: $1, by: query.ranking) }
        return BattlerRankings(
            battlers: query.showsBestOfEachSpecies ? RankBattlersHandler.keepBestOfEachSpecies(ranked) : ranked,
            catchesWithoutIVs: modern.count - withIVs.count,
            olderGenerationCatches: olderGeneration.count)
    }

    func handle(_ query: GetBattlerQuery) -> BattlerSummary? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue), !caught.isFailed, !caught.ivs.isEmpty, !RankBattlersHandler.usesDeterminantValues(caught),
              let name = pokemonRepository.getAll().first(where: { $0.number == caught.number })?.name else { return nil }
        return makeSummary(of: caught, name: name, level: query.level, countsUnusedStatFully: false)
    }

    private func makeSummary(of caught: Catch, name: String, level: BattleLevel, countsUnusedStatFully: Bool) -> BattlerSummary {
        let assessment = BattlerAssessment(caught: caught, moveCategories: moveCategories)
        let style = assessment.style
        let base = baseStats.findStats(of: caught.number, formId: caught.formId)
        let values = base.map {
            StatCalculator.calculateStats(of: caught.number, base: $0, ivs: caught.ivs, evs: caught.evs, nature: caught.nature, level: level)
        } ?? Array(repeating: nil, count: Stat.allCases.count)
        let combinedStats = base.map {
            CombinedStats(of: caught.number, base: $0, ivs: caught.ivs, evs: caught.evs, nature: caught.nature, level: level, style: style, countsUnusedStatFully: countsUnusedStatFully)
        }
        let stats = Stat.allCases.map { stat in
            BattlerStat(stat: stat, iv: caught.ivs[stat], ev: caught.evs[stat], value: values[stat.rawValue], isLessRelevant: stat == style.lessRelevantStat)
        }
        return BattlerSummary(
            id: CatchID(rawValue: caught.id),
            number: caught.number,
            pokemonName: name,
            nickname: caught.nickname,
            formId: caught.formId,
            formName: forms.findForm(caught.formId, of: caught.number)?.name,
            caughtBall: caught.caughtBall,
            game: caught.game,
            nature: caught.nature,
            ability: abilities.resolve(caught.ability, of: caught.number, formId: caught.formId, in: caught.game).map(abilities.findName),
            style: style,
            stats: stats,
            relevantIVPercent: assessment.relevantIVPercent,
            perfectCount: assessment.perfectCount,
            ivTotal: assessment.ivTotal,
            readiness: assessment.readiness,
            readinessParts: assessment.readinessParts,
            hiddenPower: HiddenPower(ivs: caught.ivs, game: caught.game),
            badges: assessment.badges,
            combinedStats: combinedStats)
    }

    private static func usesDeterminantValues(_ caught: Catch) -> Bool {
        return !IndividualValues.isUsed(in: caught.game)
    }

    private static func ranks(_ lhs: BattlerSummary, above rhs: BattlerSummary, by ranking: BattlerRanking) -> Bool {
        let order: [(BattlerSummary) -> Int]
        switch ranking {
        case .relevantIVs: order = [{ $0.relevantIVPercent }, { $0.perfectCount }, { $0.readiness }]
        case .perfectIVs: order = [{ $0.perfectCount }, { $0.ivTotal }, { $0.readiness }]
        case .ivTotal: order = [{ $0.ivTotal }, { $0.perfectCount }, { $0.readiness }]
        case .readiness: order = [{ $0.readiness }, { $0.relevantIVPercent }, { $0.perfectCount }]
        case .combinedStats: order = [{ $0.combinedStats?.total ?? 0 }, { $0.relevantIVPercent }, { $0.perfectCount }]
        }
        for score in order where score(lhs) != score(rhs) {
            return score(lhs) > score(rhs)
        }
        return lhs.number < rhs.number
    }

    private static func keepBestOfEachSpecies(_ ranked: [BattlerSummary]) -> [BattlerSummary] {
        let countsByNumber = Dictionary(grouping: ranked, by: { $0.number }).mapValues { $0.count }
        var seenNumbers = Set<Int>()
        return ranked.compactMap { battler in
            guard seenNumbers.insert(battler.number).inserted else { return nil }
            var best = battler
            best.duplicateCount = countsByNumber[battler.number, default: 1] - 1
            return best
        }
    }
}
