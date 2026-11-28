import Foundation

struct GetNextHuntQuery {}

struct NextHunt: Equatable {
    let journeyId: JourneyID
    let journeyName: String
    let number: Int
    let pokemonName: String
    let formId: String?
    let suggestion: HuntSuggestionSummary
}

final class GetNextHuntHandler {
    private let journeyRepository: JourneyRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let finder: HuntSuggestionFinder

    init(journeyRepository: JourneyRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, finder: HuntSuggestionFinder) {
        self.journeyRepository = journeyRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.finder = finder
    }

    func handle(_ query: GetNextHuntQuery) -> NextHunt? {
        let allPokemon = pokemonRepository.getAll()
        let catchesById = Dictionary(catchRepository.getAll().filter { !$0.isFailed }.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let preferredGames = finder.findPreferredGames()
        for journey in journeyRepository.getAll().sorted(by: { $0.priority < $1.priority }) {
            let uncaught = journey.entries.filter { journey.findLinkedCatch(for: $0, in: catchesById) == nil }
            let candidates = uncaught.compactMap { entry -> NextHunt? in
                guard let name = allPokemon[safe: entry.number]?.name,
                      let suggestion = finder.findSuggestion(for: entry.number, preferring: preferredGames, allPokemon: allPokemon, for: journey.game) else { return nil }
                return NextHunt(journeyId: JourneyID(rawValue: journey.id), journeyName: journey.name, number: entry.number, pokemonName: name, formId: entry.formId,
                                suggestion: suggestion)
            }
            if let best = candidates.min(by: { $0.suggestion.odds < $1.suggestion.odds }) {
                return best
            }
        }
        return nil
    }
}
