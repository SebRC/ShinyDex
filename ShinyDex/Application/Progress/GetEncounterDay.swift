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
    var shinies: [CatchSummary] = []
}

final class GetEncounterDayHandler {
    private let dailyEncountersRepository: DailyEncountersRepository
    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let forms: PokemonForms
    private let calendar: Calendar

    init(dailyEncountersRepository: DailyEncountersRepository, pokemonRepository: PokemonRepository, catchRepository: CatchRepository,
         forms: PokemonForms = PokemonForms(), calendar: Calendar = .current) {
        self.dailyEncountersRepository = dailyEncountersRepository
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        self.forms = forms
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
                                     unsplitCount: encounters.unsplitCount, splitSince: firstSplitDay?.makeDate(in: calendar),
                                     shinies: findShinies(on: query.date))
    }

    private func findShinies(on date: Date) -> [CatchSummary] {
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        return catchRepository.getAll()
            .compactMap { caught in caught.caughtDate.map { (caught: caught, date: $0) } }
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
            .compactMap { mapper.makeSummary(of: $0.caught) }
    }

    private static func calculateSharePercent(of count: Int, in total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(count) / Double(total) * 100).rounded())
    }
}
