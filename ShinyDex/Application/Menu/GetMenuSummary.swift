import Foundation

struct GetMenuSummaryQuery {}

struct MenuSummary: Equatable {
    struct RegionProgress: Equatable {
        let caught: Int
        let total: Int
    }

    let huntCount: Int
    let huntEncounters: Int
    let firstHuntPokemonName: String?
    let caughtCount: Int
    let averageEncounters: Int?
    let journeyCount: Int
    let completeJourneyCount: Int
    let regionProgress: [Int: RegionProgress]
}

final class GetMenuSummaryHandler {
    private let getHunts: GetHuntsHandler
    private let getJourneys: GetJourneysHandler
    private let catchRepository: CatchRepository

    init(getHunts: GetHuntsHandler, getJourneys: GetJourneysHandler, catchRepository: CatchRepository) {
        self.getHunts = getHunts
        self.getJourneys = getJourneys
        self.catchRepository = catchRepository
    }

    func handle(_ query: GetMenuSummaryQuery) -> MenuSummary {
        let hunts = getHunts.handle(GetHuntsQuery())
        let journeys = getJourneys.handle(GetJourneysQuery())
        let allCatches = catchRepository.getAll()
        let caught = allCatches.filter { !$0.isFailed }
        let catchCounts = CatchRules.countsByNumber(caught)
        var regionProgress = [Int: MenuSummary.RegionProgress]()
        for region in 0...9 {
            guard let range = PokedexRegions.numbers(inRegion: region) else { continue }
            regionProgress[region] = MenuSummary.RegionProgress(caught: range.filter { (catchCounts[$0] ?? 0) > 0 }.count, total: range.count)
        }
        return MenuSummary(
            huntCount: hunts.count,
            huntEncounters: hunts.reduce(0) { $0 + $1.totalEncounters },
            firstHuntPokemonName: hunts.first?.members.first?.name,
            caughtCount: caught.count,
            averageEncounters: CatchStats(catches: allCatches).averageEncounters,
            journeyCount: journeys.count,
            completeJourneyCount: journeys.filter { $0.isComplete }.count,
            regionProgress: regionProgress)
    }
}
