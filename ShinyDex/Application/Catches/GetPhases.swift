import Foundation

struct GetPhasesQuery {
    enum Source {
        case hunt(number: Int)
        case caught(CatchID)
    }

    let source: Source
}

struct PhaseList: Equatable {
    struct Phase: Equatable {
        let caught: CatchSummary
        let foundAt: Int
        let encounters: Int
    }

    let targetName: String
    let phases: [Phase]
    let encountersAfterPhases: Int
    let isHunt: Bool
}

final class GetPhasesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let genders: PokemonGenders

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), genders: PokemonGenders = PokemonGenders()) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.genders = genders
    }

    func handle(_ query: GetPhasesQuery) -> PhaseList? {
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms, genders: genders)
        switch query.source {
        case .hunt(let number):
            guard let hunted = pokemonRepository.get(number: number) else { return nil }
            var previousMark = 0
            let phases = hunted.phases.compactMap { phase -> PhaseList.Phase? in
                defer { previousMark = phase.encounters }
                guard let caught = catchRepository.get(id: phase.catchId), let summary = mapper.makeSummary(of: caught) else { return nil }
                return PhaseList.Phase(caught: summary, foundAt: phase.encounters, encounters: max(phase.encounters - previousMark, 0))
            }
            return PhaseList(targetName: hunted.name, phases: phases, encountersAfterPhases: max(hunted.encounters - (hunted.phases.last?.encounters ?? 0), 0), isHunt: true)
        case .caught(let catchId):
            guard let target = catchRepository.get(id: catchId.rawValue), let targetName = mapper.namesByNumber[target.number] else { return nil }
            var foundAt = 0
            let phaseCatches = CatchRules.sortedByKnownDateFirst(target.phaseCatchIds.compactMap { catchRepository.get(id: $0) })
            let phases = phaseCatches.compactMap { caught -> PhaseList.Phase? in
                guard let summary = mapper.makeSummary(of: caught) else { return nil }
                foundAt += caught.encounters
                return PhaseList.Phase(caught: summary, foundAt: foundAt, encounters: caught.encounters)
            }
            return PhaseList(targetName: targetName, phases: phases, encountersAfterPhases: max(target.encounters - foundAt, 0), isHunt: false)
        }
    }
}
