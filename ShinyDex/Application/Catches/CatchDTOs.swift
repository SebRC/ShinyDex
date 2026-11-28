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
    var level: Int? = nil
}

struct AbilityChoice: Equatable {
    let id: String
    let name: String
    let isHidden: Bool
}

struct MoveChoice: Equatable {
    let id: Int
    let name: String
    let type: String
    let pp: Int
    var learnedIn: Games? = nil
    var learnedAs: String? = nil

    var isNative: Bool {
        return learnedIn == nil && learnedAs == nil
    }
}

struct LearnableMoves: Equatable {
    enum Method: Equatable {
        case levelUp
        case machine
        case egg
        case tutor
    }

    struct Section: Equatable {
        let method: Method
        let moves: [MoveChoice]
    }

    let pokemonName: String
    let game: Games
    let knownMoves: [MoveChoice]
    let sections: [Section]
    var generation: Int? = nil
}

struct CatchGender: Equatable {
    let value: Gender?
    let choices: [Gender]

    var isFixed: Bool {
        return choices.count == 1
    }
}

struct CatchAbility: Equatable {
    let name: String?
    let choices: [AbilityChoice]

    var isFixed: Bool {
        return choices.count == 1
    }
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
    var moves: [MoveChoice] = []
    var gender = CatchGender(value: nil, choices: [.male, .female])
    var phaseCount = 0
}

struct CatchSummaryMapper {
    let namesByNumber: [Int: String]
    let forms: PokemonForms
    let genders: PokemonGenders

    init(allPokemon: [Pokemon], forms: PokemonForms, genders: PokemonGenders = PokemonGenders()) {
        namesByNumber = Dictionary(allPokemon.map { ($0.number, $0.name) }, uniquingKeysWith: { first, _ in first })
        self.forms = forms
        self.genders = genders
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
            gender: genders.resolve(caught.gender, for: caught.number),
            nature: caught.nature,
            ivs: caught.ivs,
            formId: caught.formId,
            formName: forms.findForm(caught.formId, of: caught.number)?.name,
            ability: caught.ability,
            level: caught.level)
    }
}
