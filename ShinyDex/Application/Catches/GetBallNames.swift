import Foundation

struct GetBallNamesQuery {}

final class GetBallNamesHandler {
    private let resourceLoader: ResourceLoader

    init(resourceLoader: ResourceLoader) {
        self.resourceLoader = resourceLoader
    }

    func handle(_ query: GetBallNamesQuery) -> [String] {
        return resourceLoader.lines(ofTextResource: "pokeballs").filter { $0 != CatchRules.noBall }
    }
}
