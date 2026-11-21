import Foundation

struct IncrementAllInHuntCommand {
    let huntId: HuntID
}

final class IncrementAllInHuntHandler {
    private let huntRepository: HuntRepository
    private let changeEncounters: ChangeEncountersHandler

    init(huntRepository: HuntRepository, changeEncounters: ChangeEncountersHandler) {
        self.huntRepository = huntRepository
        self.changeEncounters = changeEncounters
    }

    @discardableResult
    func handle(_ command: IncrementAllInHuntCommand) -> [ReachedMilestone] {
        guard let hunt = huntRepository.getAll().first(where: { $0.id == command.huntId.rawValue }) else { return [] }
        return hunt.indexes.compactMap { number in
            changeEncounters.handle(ChangeEncountersCommand(number: number, change: .increment))
        }
    }
}
