import Foundation

struct CatchSummary: Equatable {
    let id: CatchID
    let number: Int
    let pokemonName: String
    let caughtBall: String
    let game: Games
    let huntMethod: HuntMethod
    let encounters: Int
    let isShinyCharmActive: Bool
    let caughtDate: Date?
    let isFailed: Bool
    let evs: EffortValues
    let evolvedFrom: Int?
    let nickname: String?
    let gender: Gender?
    let nature: Nature?
    let ivs: IndividualValues
    let formId: String?
    let formName: String?
    var ability: String? = nil
}

struct AbilityChoice: Equatable {
    let id: String
    let name: String
    let isHidden: Bool
}

struct CatchAbility: Equatable {
    let name: String?
    let choices: [AbilityChoice]
}

struct NamedPokemon: Equatable {
    let number: Int
    let name: String
}

struct CatchDetails: Equatable {
    let summary: CatchSummary
    let evolvedFromName: String?
    let evolutionTargets: [NamedPokemon]
    let odds: Int?
    let chanceOfFindingSooner: Double?
    let position: Int?
    let speciesCatchCount: Int
    let formChoices: FormChoices?
    var ability: CatchAbility? = nil
}

struct CatchSummaryMapper {
    let namesByNumber: [Int: String]
    let forms: PokemonForms

    init(allPokemon: [Pokemon], forms: PokemonForms) {
        namesByNumber = Dictionary(allPokemon.map { ($0.number, $0.name) }, uniquingKeysWith: { first, _ in first })
        self.forms = forms
    }

    func makeSummary(of caught: Catch) -> CatchSummary? {
        guard let name = namesByNumber[caught.number] else { return nil }
        return CatchSummary(
            id: CatchID(rawValue: caught.id),
            number: caught.number,
            pokemonName: name,
            caughtBall: caught.caughtBall,
            game: caught.game,
            huntMethod: caught.huntMethod,
            encounters: caught.encounters,
            isShinyCharmActive: caught.isShinyCharmActive,
            caughtDate: caught.caughtDate,
            isFailed: caught.isFailed,
            evs: caught.evs,
            evolvedFrom: caught.evolvedFrom,
            nickname: caught.nickname,
            gender: caught.gender,
            nature: caught.nature,
            ivs: caught.ivs,
            formId: caught.formId,
            formName: forms.findForm(caught.formId, of: caught.number)?.name,
            ability: caught.ability)
    }
}
