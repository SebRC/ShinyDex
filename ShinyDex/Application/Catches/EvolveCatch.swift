import Foundation

struct EvolveCatchCommand {
    let catchId: CatchID
    let targetNumber: Int
}

final class EvolveCatchHandler {
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let abilities: PokemonAbilities

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), abilities: PokemonAbilities = PokemonAbilities()) {
        self.forms = forms
        self.abilities = abilities
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: EvolveCatchCommand) throws {
        guard let caught = catchRepository.get(id: command.catchId.rawValue) else { throw CatchUpdateError.notFound }
        let previousNumber = caught.number
        let originalNumber = caught.evolvedFrom ?? caught.number
        let previousForm = PokemonAbilities.Key(number: caught.number, formId: caught.formId)
        caught.formId = forms.carryOver(caught.formId, to: command.targetNumber)
        caught.ability = abilities.carryOver(caught.ability, from: previousForm, to: PokemonAbilities.Key(number: command.targetNumber, formId: caught.formId), in: caught.game)
        caught.number = command.targetNumber
        caught.evolvedFrom = originalNumber == command.targetNumber ? nil : originalNumber
        catchRepository.update(caught)
        guard catchRepository.save() else { throw CatchUpdateError.saveFailed }
        let sync = CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository)
        sync.sync(number: previousNumber)
        sync.sync(number: command.targetNumber)
    }
}
