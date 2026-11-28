import Foundation

struct GetTrainingPlanQuery {
    let catchId: CatchID
    var spread: TrainingSpread?
    var level = BattleLevel.fifty
}

struct TrainingStatPlan: Equatable {
    let stat: Stat
    let current: Int
    let target: Int
    let remaining: Int
    let excess: Int
    let value: Int?
    let plannedValue: Int?
}

struct TrainingPlanDetails: Equatable {
    let spread: TrainingSpread
    let suggestedSpread: TrainingSpread
    let style: AttackingStyle
    let level: BattleLevel
    let stats: [TrainingStatPlan]
    let remaining: Int
    let excess: Int
    let isComplete: Bool
}

final class GetTrainingPlanHandler {
    private let catchRepository: CatchRepository
    private let baseStats: PokemonBaseStats
    private let moveCategories: MoveCategories

    init(catchRepository: CatchRepository, baseStats: PokemonBaseStats = PokemonBaseStats(), moveCategories: MoveCategories = MoveCategories()) {
        self.catchRepository = catchRepository
        self.baseStats = baseStats
        self.moveCategories = moveCategories
    }

    func handle(_ query: GetTrainingPlanQuery) -> TrainingPlanDetails? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue) else { return nil }
        let assessment = BattlerAssessment(caught: caught, moveCategories: moveCategories)
        let base = baseStats.findStats(of: caught.number, formId: caught.formId)
        let suggested = TrainingPlan.suggestSpread(style: assessment.style, nature: caught.nature, base: base, isTrickRoomBattler: assessment.isTrickRoomBattler)
        let plan = TrainingPlan(spread: query.spread ?? suggested, current: caught.evs, style: assessment.style, nature: caught.nature, base: base)
        let values = makeValues(of: caught, base: base, evs: caught.evs, level: query.level)
        let plannedValues = makeValues(of: caught, base: base, evs: plan.targets, level: query.level)
        return TrainingPlanDetails(
            spread: plan.spread,
            suggestedSpread: suggested,
            style: assessment.style,
            level: query.level,
            stats: plan.stats.map { statPlan in
                TrainingStatPlan(stat: statPlan.stat, current: statPlan.current, target: statPlan.target, remaining: statPlan.remaining, excess: statPlan.excess,
                                 value: values[statPlan.stat.rawValue], plannedValue: plannedValues[statPlan.stat.rawValue])
            },
            remaining: plan.remaining,
            excess: plan.excess,
            isComplete: plan.isComplete)
    }

    private func makeValues(of caught: Catch, base: BaseStats?, evs: EffortValues, level: BattleLevel) -> [Int?] {
        guard let base = base else { return Array(repeating: nil, count: Stat.allCases.count) }
        return StatCalculator.calculateStats(of: caught.number, base: base, ivs: caught.ivs, evs: evs, nature: caught.nature, level: level)
    }
}
