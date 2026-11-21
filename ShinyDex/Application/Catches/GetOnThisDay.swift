import Foundation

struct GetOnThisDayQuery {}

struct OnThisDayCatch: Equatable {
    let caught: CatchSummary
    let yearsAgo: Int
}

final class GetOnThisDayHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(),
         calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ query: GetOnThisDayQuery) -> [OnThisDayCatch] {
        let today = calendar.dateComponents([.year, .month, .day], from: makeCurrentDate())
        guard let currentYear = today.year else { return [] }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        return catchRepository.getAll()
            .compactMap { caught -> (caught: Catch, date: Date, year: Int)? in
                guard let date = caught.caughtDate else { return nil }
                let found = calendar.dateComponents([.year, .month, .day], from: date)
                guard let year = found.year, year < currentYear, matchesToday(found, today: today, currentYear: currentYear) else { return nil }
                return (caught, date, year)
            }
            .sorted { $0.year != $1.year ? $0.year > $1.year : $0.date < $1.date }
            .compactMap { match in
                mapper.makeSummary(of: match.caught).map { OnThisDayCatch(caught: $0, yearsAgo: currentYear - match.year) }
            }
    }

    private func matchesToday(_ found: DateComponents, today: DateComponents, currentYear: Int) -> Bool {
        if found.month == today.month && found.day == today.day {
            return true
        }
        let isLeapDay = found.month == 2 && found.day == 29
        let isLastDayOfShortFebruary = today.month == 2 && today.day == 28 && !isLeapYear(currentYear)
        return isLeapDay && isLastDayOfShortFebruary
    }

    private func isLeapYear(_ year: Int) -> Bool {
        return calendar.range(of: .day, in: .year, for: calendar.date(from: DateComponents(year: year)) ?? Date())?.count == 366
    }
}
