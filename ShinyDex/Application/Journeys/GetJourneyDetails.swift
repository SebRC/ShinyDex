import Foundation

struct GetJourneyDetailsQuery {
    let journeyId: JourneyID
}

final class GetJourneyDetailsHandler {
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

    func handle(_ query: GetJourneyDetailsQuery) -> JourneyDetails? {
        guard let journey = journeyRepository.getAll().first(where: { $0.id == query.journeyId.rawValue }) else { return nil }
        let allPokemon = pokemonRepository.getAll()
        let mapper = CatchSummaryMapper(allPokemon: allPokemon)
        let links = JourneyCatchLinks(catches: catchRepository.getAll(), evolutions: evolutions)
        let entries = journey.entries.map { entry -> JourneyEntryDetails in
            let linked = journey.linkedCatch(for: entry, in: links.catchesById)
            return JourneyEntryDetails(
                id: JourneyEntryID(rawValue: entry.id),
                number: entry.number,
                pokemonName: allPokemon[safe: entry.number]?.name,
                linkedCatch: linked.flatMap(mapper.summary),
                linkableCatchCount: linked == nil ? links.linkable(for: entry, in: journey).count : 0,
                phases: journey.phases(for: entry, in: links.catchesById).compactMap(mapper.summary))
        }
        let timeline = journey.timeline(in: links.catchesById).compactMap { step in
            mapper.summary(of: step.caught).map { JourneyTimelineStep(caught: $0, isPhase: step.isPhase, entryPokemonName: allPokemon[safe: step.entry.number]?.name) }
        }
        return JourneyDetails(id: query.journeyId, name: journey.name, entries: entries, timeline: timeline)
    }
}
