import Foundation

enum EvolutionsLoader {
    private struct File: Decodable {
        let evolvesFrom: [Int]
    }

    static func load(from resourceLoader: ResourceLoader) -> Evolutions {
        guard let data = resourceLoader.data(ofResource: "evolutions", withExtension: "json"),
              let file = try? JSONDecoder().decode(File.self, from: data) else {
            return Evolutions(evolvesFrom: [])
        }
        return Evolutions(evolvesFrom: file.evolvesFrom)
    }
}
