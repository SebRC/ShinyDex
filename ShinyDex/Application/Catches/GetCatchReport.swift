import Foundation

struct GetCatchReportQuery {
    let catchId: CatchID
}

struct CatchReport: Equatable {
    let caught: CatchSummary
    let shinyNumber: Int
    let speciesCatchNumber: Int
    let odds: Int?
    let chanceOfFindingSooner: Double?
    let daysHunted: Int?
    let activeDays: Int?
    let phases: [CatchSummary]
    let encounterRank: Int?
    let rankedHuntCount: Int
}

final class GetCatchReportHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let forms: PokemonForms
    private let calendar: Calendar

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, dailyEncountersRepository: DailyEncountersRepository, forms: PokemonForms = PokemonForms(),
         calendar: Calendar = .current) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.forms = forms
        self.calendar = calendar
    }

    func handle(_ query: GetCatchReportQuery) -> CatchReport? {
        let all = catchRepository.getAll()
        guard let caught = all.first(where: { $0.id == query.catchId.rawValue }), !caught.isFailed else { return nil }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        guard let summary = mapper.makeSummary(of: caught) else { return nil }
        let kept = all.filter { !$0.isFailed }
        let foundBefore = { (other: Catch) in GetCatchReportHandler.isFound(other, before: caught) }
        let sameSpecies = kept.filter { $0.number == caught.number }
        let ranked = kept.filter { $0.encounters > 0 }
        let catchesById = Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let huntLength = findHuntLength(of: caught, among: sameSpecies)
        return CatchReport(
            caught: summary,
            shinyNumber: kept.filter(foundBefore).count + 1,
            speciesCatchNumber: sameSpecies.filter(foundBefore).count + 1,
            odds: CatchOdds.getOdds(for: caught),
            chanceOfFindingSooner: CatchOdds.calculateChanceOfFindingSooner(caught),
            daysHunted: huntLength?.days,
            activeDays: huntLength?.activeDays,
            phases: caught.phaseCatchIds.compactMap { catchesById[$0] }.compactMap(mapper.makeSummary),
            encounterRank: caught.encounters > 0 ? ranked.filter { $0.encounters < caught.encounters }.count + 1 : nil,
            rankedHuntCount: ranked.count)
    }

    private func findHuntLength(of caught: Catch, among sameSpecies: [Catch]) -> HuntLength? {
        guard let caughtDate = caught.caughtDate else { return nil }
        let previousFind = sameSpecies
            .filter { $0.id != caught.id && GetCatchReportHandler.isFound($0, before: caught) }
            .compactMap { $0.caughtDate }
            .max()
        return HuntLength(of: caught.number, endingOn: EncounterDay(containing: caughtDate, calendar: calendar),
                          after: previousFind.map { EncounterDay(containing: $0, calendar: calendar) }, days: dailyEncountersRepository.getAll(), calendar: calendar)
    }

    private static func isFound(_ other: Catch, before caught: Catch) -> Bool {
        guard other.id != caught.id else { return false }
        guard let otherDate = other.caughtDate else { return true }
        guard let caughtDate = caught.caughtDate else { return false }
        return otherDate < caughtDate
    }
}
