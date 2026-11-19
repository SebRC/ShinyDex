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

    func handle(_ command: IncrementAllInHuntCommand) {
        guard let hunt = huntRepository.getAll().first(where: { $0.id == command.huntId.rawValue }) else { return }
        for number in hunt.indexes {
            changeEncounters.handle(ChangeEncountersCommand(number: number, change: .increment))
        }
    }
}
