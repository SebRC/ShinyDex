import Foundation

struct GetLearnableMovesQuery {
    let catchId: CatchID
}

final class GetLearnableMovesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let learnsets: PokemonLearnsets
    private let evolutions: Evolutions

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, learnsets: PokemonLearnsets, evolutions: Evolutions) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.learnsets = learnsets
        self.evolutions = evolutions
    }

    func handle(_ query: GetLearnableMovesQuery) -> LearnableMoves? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue), let pokemon = pokemonRepository.get(number: caught.number) else { return nil }
        let learnset = learnsets.findGenerationLearnset(of: caught.number, formId: caught.formId, caughtIn: caught.game, evolutions: evolutions)
        let sections = MoveLearnMethod.allCases.compactMap { method -> LearnableMoves.Section? in
            guard let entries = learnset?.entriesByMethod[method], !entries.isEmpty else { return nil }
            let moves = entries.map { entry in
                MoveChoice(entry.move, learnedIn: entry.game == caught.game ? nil : entry.game,
                           learnedAs: entry.number == caught.number ? nil : pokemonRepository.get(number: entry.number)?.name)
            }
            return LearnableMoves.Section(method: GetLearnableMovesHandler.map(method), moves: moves)
        }
        let knownMoves = caught.moves.map { id in learnsets.findMove(id).map { MoveChoice($0) } ?? MoveChoice(id: id, name: "Move #\(id)", type: "", pp: 0) }
        return LearnableMoves(pokemonName: pokemon.name, game: caught.game, knownMoves: knownMoves, sections: sections, generation: GamesList.games[caught.game]?.generation)
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
    init(_ move: LearnableMove, learnedIn: Games? = nil, learnedAs: String? = nil) {
        self.init(id: move.id, name: move.name, type: move.type, pp: move.pp, learnedIn: learnedIn, learnedAs: learnedAs)
    }
}
