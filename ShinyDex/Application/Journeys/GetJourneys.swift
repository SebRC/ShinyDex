import Foundation

struct GetJourneysQuery {}

final class GetJourneysHandler {
    private let journeyRepository: JourneyRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(journeyRepository: JourneyRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.journeyRepository = journeyRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetJourneysQuery) -> [JourneySummary] {
        let allPokemon = pokemonRepository.getAll()
        let catchesById = Dictionary(catchRepository.getAll().filter { !$0.isFailed }.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return journeyRepository.getAll()
            .sorted { $0.priority < $1.priority }
            .map { journey in
                let members = journey.entries.compactMap { entry in
                    allPokemon[safe: entry.number].map { JourneyMember(number: entry.number, name: $0.name, isCaught: journey.findLinkedCatch(for: entry, in: catchesById) != nil) }
                }
                return JourneySummary(id: JourneyID(rawValue: journey.id), name: journey.name, caughtCount: journey.countCaught(in: catchesById), members: members, game: journey.game)
            }
    }
}
