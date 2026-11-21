import Foundation

struct ChangeEncountersCommand {
    enum Change: Equatable {
        case increment
        case decrement
        case set(Int)
    }

    let number: Int
    let change: Change
}

final class ChangeEncountersHandler {
    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let ledgerRepository: EncounterLedgerRepository
    private let dailyEncountersRepository: DailyEncountersRepository
    private let odds: OddsService
    private let calendar: Calendar
    private let makeCurrentDate: () -> Date

    init(pokemonRepository: PokemonRepository, catchRepository: CatchRepository, ledgerRepository: EncounterLedgerRepository,
         dailyEncountersRepository: DailyEncountersRepository, odds: OddsService, calendar: Calendar = .current, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        self.ledgerRepository = ledgerRepository
        self.dailyEncountersRepository = dailyEncountersRepository
        self.odds = odds
        self.calendar = calendar
        self.makeCurrentDate = makeCurrentDate
    }

    func handle(_ command: ChangeEncountersCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        let previousEncounters = pokemon.encounters
        switch command.change {
        case .increment:
            pokemon.encounters += pokemon.increment
        case .decrement:
            guard pokemon.encounters > 0 else { return }
            pokemon.encounters -= 1
        case .set(let encounters):
            pokemon.encounters = max(encounters, 0)
        }
        pokemon.shinyOdds = odds.getShinyOdds(pokemon: pokemon)
        pokemonRepository.save(pokemon)
        recordInLedger(command.change, from: previousEncounters, to: pokemon.encounters)
    }

    private func recordInLedger(_ change: ChangeEncountersCommand.Change, from previousEncounters: Int, to encounters: Int) {
        guard encounters != previousEncounters else { return }
        let now = makeCurrentDate()
        let ledger = ledgerRepository.get() ?? EncounterLedger(startingOn: now)
        let countedChange: Int
        switch change {
        case .increment, .set:
            countedChange = ledger.count(encounters - previousEncounters)
        case .decrement:
            let totalAtLatestFind = DryStreaks.findLatestLedgerTotalAtFind(in: catchRepository.getAll()) ?? 0
            countedChange = ledger.uncount(previousEncounters - encounters, keepingAtLeast: totalAtLatestFind)
        }
        ledgerRepository.save(ledger)
        recordForToday(countedChange, now: now)
    }

    private func recordForToday(_ countedChange: Int, now: Date) {
        guard countedChange != 0 else { return }
        let today = EncounterDay(containing: now, calendar: calendar)
        var encounters = dailyEncountersRepository.get(day: today) ?? DailyEncounters(day: today, count: 0)
        encounters.record(countedChange)
        dailyEncountersRepository.save(encounters)
    }
}
