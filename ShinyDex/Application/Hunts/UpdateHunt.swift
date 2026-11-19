import Foundation

struct UpdateHuntCommand {
    enum Change: Equatable {
        case rename(String)
        case setCollapsed(Bool)
    }

    let huntId: HuntID
    let change: Change
}

final class UpdateHuntHandler {
    private let huntRepository: HuntRepository

    init(huntRepository: HuntRepository) {
        self.huntRepository = huntRepository
    }

    func handle(_ command: UpdateHuntCommand) {
        guard let hunt = huntRepository.getAll().first(where: { $0.id == command.huntId.rawValue }) else { return }
        switch command.change {
        case .rename(let name):
            hunt.name = name
        case .setCollapsed(let isCollapsed):
            hunt.isCollapsed = isCollapsed
        }
        huntRepository.save(hunt)
    }
}
