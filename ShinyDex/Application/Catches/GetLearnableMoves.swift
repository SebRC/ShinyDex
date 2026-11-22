import Foundation

struct GetLearnableMovesQuery {
    let catchId: CatchID
}

final class GetLearnableMovesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let learnsets: PokemonLearnsets

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, learnsets: PokemonLearnsets) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.learnsets = learnsets
    }

    func handle(_ query: GetLearnableMovesQuery) -> LearnableMoves? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue), let pokemon = pokemonRepository.get(number: caught.number) else { return nil }
        let learnset = learnsets.findLearnset(of: caught.number, formId: caught.formId, in: caught.game)
        let sections = MoveLearnMethod.allCases.compactMap { method -> LearnableMoves.Section? in
            guard let moves = learnset?.movesByMethod[method], !moves.isEmpty else { return nil }
            return LearnableMoves.Section(method: GetLearnableMovesHandler.map(method), moves: moves.map(MoveChoice.init))
        }
        let knownMoves = caught.moves.map { id in learnsets.findMove(id).map(MoveChoice.init) ?? MoveChoice(id: id, name: "Move #\(id)", type: "", pp: 0) }
        return LearnableMoves(pokemonName: pokemon.name, game: caught.game, knownMoves: knownMoves, sections: sections)
    }

    private static func map(_ method: MoveLearnMethod) -> LearnableMoves.Method {
        switch method {
        case .levelUp: return .levelUp
        case .machine: return .machine
        case .egg: return .egg
        case .tutor: return .tutor
        }
    }
}

extension MoveChoice {
    init(_ move: LearnableMove) {
        self.init(id: move.id, name: move.name, type: move.type, pp: move.pp)
    }
}
