import Foundation

struct GetMoveOptionsQuery {}

final class GetMoveOptionsHandler {
    private let resourceLoader: ResourceLoader

    init(resourceLoader: ResourceLoader) {
        self.resourceLoader = resourceLoader
    }

    func handle(_ query: GetMoveOptionsQuery) -> [MoveOption] {
        guard let data = resourceLoader.loadData(ofResource: "moves", withExtension: "json"),
              let moves = try? JSONDecoder().decode([Move].self, from: data) else {
            return []
        }
        return moves
            .sorted { $0.identifier < $1.identifier }
            .map { move in
                MoveOption(
                    identifier: move.identifier,
                    name: move.identifier.replacingOccurrences(of: "-", with: " ").capitalizingFirstLetter(),
                    pp: move.pp ?? 0,
                    type: MoveTypes.types[move.type_id] ?? "")
            }
    }
}
