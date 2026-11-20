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

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms()) {
        self.forms = forms
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: LogCatchCommand) {
        guard let pokemon = pokemonRepository.get(number: command.number) else { return }
        let formId = forms.carryOver(command.formId, to: command.number)
        switch command.outcome {
        case .caught(let ball):
            catchRepository.insert(Catch(pokemon: pokemon, caughtBall: ball, caughtDate: command.date, formId: formId))
            if catchRepository.save() {
                CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: command.number)
            }
        case .gotAway:
            catchRepository.insert(Catch(pokemon: pokemon, caughtBall: CatchRules.noBall, caughtDate: command.date, isFailed: true, formId: formId))
            catchRepository.save()
        }
    }
}
