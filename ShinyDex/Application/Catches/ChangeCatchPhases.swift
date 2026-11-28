import Foundation

struct ChangeCatchPhasesCommand {
    enum Change {
        case link(CatchID)
        case unlink(CatchID)
    }

    let catchId: CatchID
    let change: Change
}

final class ChangeCatchPhasesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: ChangeCatchPhasesCommand) {
        guard let target = catchRepository.get(id: command.catchId.rawValue) else { return }
        switch command.change {
        case .link(let phaseId):
            let isLinkable = PhaseLinks(catches: catchRepository.getAll(), pokemon: pokemonRepository.getAll()).canLink(phaseId.rawValue, to: target.id)
            guard isLinkable, catchRepository.get(id: phaseId.rawValue) != nil else { return }
            target.phaseCatchIds.append(phaseId.rawValue)
        case .unlink(let phaseId):
            target.phaseCatchIds.removeAll { $0 == phaseId.rawValue }
        }
        catchRepository.update(target)
        catchRepository.save()
    }
}

struct PhaseLinks {
    let linkedIds: Set<UUID>

    init(catches: [Catch], pokemon: [Pokemon]) {
        linkedIds = Set(catches.flatMap { $0.phaseCatchIds } + pokemon.flatMap { $0.phases.map { $0.catchId } })
    }

    func canLink(_ phaseId: UUID, to targetId: UUID) -> Bool {
        return phaseId != targetId && !linkedIds.contains(phaseId)
    }
}
