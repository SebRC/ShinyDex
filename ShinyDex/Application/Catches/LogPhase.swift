import Foundation

struct LogPhaseCommand {
    let huntedNumber: Int
    let foundNumber: Int
    let outcome: LogCatchCommand.Outcome
    let date: Date
    var formId: String? = nil
}

final class LogPhaseHandler {
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

    func handle(_ command: LogPhaseCommand) {
        guard let hunted = pokemonRepository.get(number: command.huntedNumber), pokemonRepository.get(number: command.foundNumber) != nil else { return }
        let formId = forms.carryOver(command.formId, to: command.foundNumber)
        let ledger = ledgerRepository.get() ?? EncounterLedger(startingOn: makeCurrentDate())
        let encountersThisPhase = max(hunted.encounters - (hunted.phases.last?.encounters ?? 0), 0)
        let found: Catch
        switch command.outcome {
        case .caught(let ball):
            found = Catch(number: command.foundNumber, caughtBall: ball, game: hunted.game, huntMethod: hunted.huntMethod, encounters: encountersThisPhase,
                          isShinyCharmActive: hunted.isShinyCharmActive, caughtDate: command.date)
        case .gotAway:
            found = Catch(number: command.foundNumber, caughtBall: CatchRules.noBall, game: hunted.game, huntMethod: hunted.huntMethod, encounters: encountersThisPhase,
                          isShinyCharmActive: hunted.isShinyCharmActive, caughtDate: command.date, isFailed: true)
        }
        found.formId = formId
        found.encounterTotalAtFind = ledger.total
        found.gender = genders.findFixedGender(of: command.foundNumber)
        found.ability = abilities.findFixedAbility(of: command.foundNumber, formId: formId, in: found.game)
        catchRepository.insert(found)
        guard catchRepository.save() else { return }
        ledgerRepository.save(ledger)
        hunted.phases.append(HuntPhase(catchId: found.id, encounters: hunted.encounters))
        pokemonRepository.save(hunted)
        if !found.isFailed {
            CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: command.foundNumber)
        }
    }
}
