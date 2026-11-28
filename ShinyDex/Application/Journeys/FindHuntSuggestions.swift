import Foundation

struct HuntSuggestionSummary: Equatable {
    let targetNumber: Int
    let targetName: String
    let isDifferentStage: Bool
    let game: Games
    let method: HuntMethod
    let odds: Int
    let area: String?
    let isFullOdds: Bool
}

enum HuntSuggestionKeys {
    static let usesBestOdds = "huntSuggestionsUseBestOdds"
}

final class HuntSuggestionFinder {
    private let suggester: HuntSuggester
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let getMode: GetHuntSuggestionModeHandler

    init(suggester: HuntSuggester, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, getMode: GetHuntSuggestionModeHandler) {
        self.suggester = suggester
        self.getMode = getMode
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func findPreferredGames() -> [Games] {
        let catchGames = catchRepository.getAll().map { $0.game }
        let huntedGames = pokemonRepository.getAll().filter { $0.isBeingHunted }.map { $0.huntConfiguration.game }
        let counts = Dictionary((catchGames + huntedGames).map { ($0, 1) }, uniquingKeysWith: +)
        return counts.keys.sorted { counts[$0]! != counts[$1]! ? counts[$0]! > counts[$1]! : $0.rawValue < $1.rawValue }
    }

    func findSuggestion(for number: Int, preferring games: [Games], allPokemon: [Pokemon], for journeyGame: Games? = nil) -> HuntSuggestionSummary? {
        let mode = getMode.handle(GetHuntSuggestionModeQuery())
        guard let suggestion = suggester.suggest(for: number, preferring: games, mode: mode, for: journeyGame), let target = allPokemon[safe: suggestion.target] else { return nil }
        return HuntSuggestionSummary(targetNumber: suggestion.target, targetName: target.name, isDifferentStage: suggestion.target != number, game: suggestion.game,
                                     method: suggestion.method, odds: suggestion.odds, area: suggestion.area, isFullOdds: mode == .fullOdds)
    }
}
