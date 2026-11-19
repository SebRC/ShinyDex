import Foundation

struct ReorderHuntsCommand {
    let orderedIds: [HuntID]
}

final class ReorderHuntsHandler {
    private let huntRepository: HuntRepository

    init(huntRepository: HuntRepository) {
        self.huntRepository = huntRepository
    }

    func handle(_ command: ReorderHuntsCommand) {
        let huntsById = Dictionary(huntRepository.getAll().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for (priority, id) in command.orderedIds.enumerated() {
            guard let hunt = huntsById[id.rawValue] else { continue }
            hunt.priority = priority
            huntRepository.save(hunt)
        }
    }
}
