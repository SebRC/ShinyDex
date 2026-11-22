import Foundation

struct GetEncounterDayQuery {
    let date: Date
}

struct EncounterDayBreakdown: Equatable {
    struct PokemonShare: Equatable {
        let number: Int
        let name: String
        let count: Int
        let sharePercent: Int
    }

    let date: Date
    let total: Int
    let pokemon: [PokemonShare]
    let unsplitCount: Int
    let splitSince: Date?
}

final class GetEncounterDayHandler {
    private let dailyEncountersRepository: DailyEncountersRepository
    private let pokemonRepository: PokemonRepository
    private let calendar: Calendar

    init(dailyEncountersRepository: DailyEncountersRepository, pokemonRepository: PokemonRepository, calendar: Calendar = .current) {
        self.dailyEncountersRepository = dailyEncountersRepository
        self.pokemonRepository = pokemonRepository
        self.calendar = calendar
    }

    func handle(_ query: GetEncounterDayQuery) -> EncounterDayBreakdown {
        let day = EncounterDay(containing: query.date, calendar: calendar)
        let encounters = dailyEncountersRepository.get(day: day) ?? DailyEncounters(day: day, count: 0)
        let pokemon = encounters.countsByPokemon
            .compactMap { number, count -> EncounterDayBreakdown.PokemonShare? in
                guard let name = pokemonRepository.get(number: number)?.name else { return nil }
                return EncounterDayBreakdown.PokemonShare(number: number, name: name, count: count,
                                                          sharePercent: GetEncounterDayHandler.calculateSharePercent(of: count, in: encounters.count))
            }
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.number < $1.number }
        let firstSplitDay = dailyEncountersRepository.getAll().filter { !$0.countsByPokemon.isEmpty }.map { $0.day }.min()
        return EncounterDayBreakdown(date: calendar.startOfDay(for: query.date), total: encounters.count, pokemon: pokemon,
                                     unsplitCount: encounters.unsplitCount, splitSince: firstSplitDay?.makeDate(in: calendar))
    }

    private static func calculateSharePercent(of count: Int, in total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(count) / Double(total) * 100).rounded())
    }
}
