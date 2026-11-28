import Foundation

struct GetJourneyPlaybackQuery {
    let journeyId: JourneyID
}

final class GetJourneyPlaybackHandler {
    private let journeyRepository: JourneyRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let keyValueStore: KeyValueStore
    private let forms: PokemonForms

    init(journeyRepository: JourneyRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, keyValueStore: KeyValueStore, forms: PokemonForms = PokemonForms()) {
        self.journeyRepository = journeyRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.keyValueStore = keyValueStore
        self.forms = forms
    }

    func handle(_ query: GetJourneyPlaybackQuery) -> JourneyPlayback? {
        guard let journey = journeyRepository.getAll().first(where: { $0.id == query.journeyId.rawValue }) else { return nil }
        let catchesById = Dictionary(catchRepository.getAll().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let companions = journey.findPlaybackCompanions(in: catchesById)
        guard !companions.isEmpty else { return nil }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        return JourneyPlayback(journeyName: journey.name,
                               companions: companions.compactMap(mapper.makeSummary),
                               games: Journey.rankPlaybackGames(of: companions),
                               isPlayerFemale: keyValueStore.getBool(forKey: JourneyPlaybackKeys.isPlayerFemale),
                               luckiestFind: GetJourneyPlaybackHandler.findLuckiest(of: companions))
    }

    private static func findLuckiest(of companions: [Catch]) -> JourneyPlayback.LuckiestFind? {
        let chances = companions.compactMap { caught in CatchOdds.calculateChanceOfFindingSooner(caught).map { (caught, $0) } }
        guard let luckiest = chances.min(by: { $0.1 < $1.1 }) else { return nil }
        return JourneyPlayback.LuckiestFind(catchId: CatchID(rawValue: luckiest.0.id), chanceOfFindingSooner: luckiest.1)
    }
}
