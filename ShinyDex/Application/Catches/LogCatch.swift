import Foundation

struct LogCatchCommand {
    enum Outcome: Equatable {
        case caught(ball: String)
        case gotAway
    }

    let number: Int
    let outcome: Outcome
    let date: Date
    var formId: String? = nil
}

final class LogCatchHandler {
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let ledgerRepository: EncounterLedgerRepository
    private let genders: PokemonGenders
    private let abilities: PokemonAbilities
    private let makeCurrentDate: () -> Date

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, ledgerRepository: EncounterLedgerRepository, forms: PokemonForms = PokemonForms(),
         genders: PokemonGenders = PokemonGenders(), abilities: PokemonAbilities = PokemonAbilities(), makeCurrentDate: @escaping () -> Date = Date.init) {
        self.forms = forms
        self.genders = genders
        self.abilities = abilities
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.ledgerRepository = ledgerRepository
        self.makeCurrentDate = makeCurrentDate
    }

    @discardableResult
    func handle(_ command: LogCatchCommand) -> CatchID? {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return nil }
        let formId = forms.carryOver(command.formId, to: command.number)
        let ledger = ledgerRepository.get() ?? EncounterLedger(startingOn: makeCurrentDate())
        let found: Catch
        switch command.outcome {
        case .caught(let ball):
            found = Catch(pokemon: pokemon, caughtBall: ball, caughtDate: command.date, formId: formId)
        case .gotAway:
            found = Catch(pokemon: pokemon, caughtBall: CatchRules.noBall, caughtDate: command.date, isFailed: true, formId: formId)
        }
        found.encounterTotalAtFind = ledger.total
        found.phaseCatchIds = pokemon.phases.map { $0.catchId }
        found.gender = genders.findFixedGender(of: command.number)
        found.ability = abilities.findFixedAbility(of: command.number, formId: formId, in: found.game)
        catchRepository.insert(found)
        guard catchRepository.save() else { return nil }
        ledgerRepository.save(ledger)
        if (!pokemon.phases.isEmpty) {
            pokemon.phases = []
            pokemonRepository.save(pokemon)
        }
        if !found.isFailed {
            CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: command.number)
        }
        return CatchID(rawValue: found.id)
    }
}
