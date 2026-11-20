import Foundation

struct GetLinkableCatchesQuery {
    let journeyId: JourneyID
    let entryId: JourneyEntryID
    var role = JourneyCatchRole.target
}

final class GetLinkableCatchesHandler {
    private let journeyRepository: JourneyRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let evolutions: Evolutions

    init(journeyRepository: JourneyRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, evolutions: Evolutions) {
        self.journeyRepository = journeyRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.evolutions = evolutions
    }

    func handle(_ query: GetLinkableCatchesQuery) -> [CatchSummary] {
        guard let journey = journeyRepository.getAll().first(where: { $0.id == query.journeyId.rawValue }),
              let entry = journey.entries.first(where: { $0.id == query.entryId.rawValue }) else { return [] }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll())
        let links = JourneyCatchLinks(catches: catchRepository.getAll(), evolutions: evolutions)
        return links.findLinkableCatches(for: entry, in: journey, as: query.role).compactMap(mapper.makeSummary)
    }
}
