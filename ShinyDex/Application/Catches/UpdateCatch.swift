import Foundation

enum CatchUpdateError: Error, Equatable {
    case notFound
    case saveFailed
}

struct UpdateCatchCommand {
    enum Change: Equatable {
        case ball(String)
        case game(Games)
        case huntMethod(HuntMethod)
        case encounters(Int)
        case caughtDate(Date?)
        case evs(EffortValues)
        case nickname(String?)
        case gender(Gender?)
        case nature(Nature?)
        case ivs(IndividualValues)
        case form(String?)
        case ability(String?)
        case moves([Int])
    }

    let catchId: CatchID
    let change: Change
}

final class UpdateCatchHandler {
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let abilities: PokemonAbilities
    private let genders: PokemonGenders

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), abilities: PokemonAbilities = PokemonAbilities(),
         genders: PokemonGenders = PokemonGenders()) {
        self.forms = forms
        self.genders = genders
        self.abilities = abilities
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: UpdateCatchCommand) throws {
        guard let caught = catchRepository.get(id: command.catchId.rawValue) else { throw CatchUpdateError.notFound }
        switch command.change {
        case .ball(let ball): caught.caughtBall = ball
        case .game(let game):
            caught.game = game
            caught.ability = abilities.resolve(caught.ability, of: caught.number, formId: caught.formId, in: game)
        case .huntMethod(let method): caught.huntMethod = method
        case .encounters(let encounters): caught.encounters = encounters
        case .caughtDate(let date): caught.caughtDate = date
        case .evs(let evs): caught.evs = evs
        case .nickname(let nickname): caught.nickname = nickname
        case .gender(let gender): caught.gender = genders.resolve(gender, for: caught.number)
        case .nature(let nature): caught.nature = nature
        case .ivs(let ivs): caught.ivs = ivs
        case .form(let formId):
            let previousForm = PokemonAbilities.Key(number: caught.number, formId: caught.formId)
            caught.formId = forms.carryOver(formId, to: caught.number)
            caught.ability = abilities.carryOver(caught.ability, from: previousForm, to: PokemonAbilities.Key(number: caught.number, formId: caught.formId), in: caught.game)
        case .ability(let ability): caught.ability = abilities.resolve(ability, of: caught.number, formId: caught.formId, in: caught.game)
        case .moves(let moves): caught.moves = moves
        }
        catchRepository.update(caught)
        guard catchRepository.save() else { throw CatchUpdateError.saveFailed }
        CaughtBallSync(catchRepository: catchRepository, pokemonRepository: pokemonRepository).sync(number: caught.number)
    }
}
