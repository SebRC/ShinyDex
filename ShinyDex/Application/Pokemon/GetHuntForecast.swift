import Foundation

struct GetHuntForecastQuery {
    let number: Int
}

struct HuntForecast: Equatable {
    let encountersPerDay: Int
    let activeDays: Int
    let daysToOdds: Int?
}

final class GetHuntForecastHandler {
    private let pokemonRepository: PokemonRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let odds: OddsService
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(pokemonRepository: PokemonRepository, dailyEncountersRepository: DailyEncountersRepository, odds: OddsService,
         calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.pokemonRepository = pokemonRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.odds = odds
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetHuntForecastQuery) -> HuntForecast? {
        guard let pokemon = pokemonRepository.get(number: query.number), let pace = findPace(of: query.number) else { return nil }
        let configuration = pokemon.huntConfiguration
        let daysToOdds = configuration.usesChain ? nil : pace.estimateDays(toCover: odds.getShinyOdds(configuration: configuration, chain: 0) - pokemon.encounters)
        return HuntForecast(encountersPerDay: pace.encountersPerDay, activeDays: pace.activeDays, daysToOdds: daysToOdds)
    }

    func findPace(of number: Int) -> HuntPace? {
        return HuntPace(number: number, dailyEncounters: dailyEncountersRepository.getAll(),
                        today: EncounterDay(containing: makeCurrentDate(), calendar: calendar), calendar: calendar)
    }
}
