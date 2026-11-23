import Foundation

enum MoveCategoriesLoader {
    private struct Entry: Decodable {
        let id: Int
        let damage_class_id: Int
    }

    static func load(from resourceLoader: ResourceLoader) -> MoveCategories {
        guard let data = resourceLoader.loadData(ofResource: "moves", withExtension: "json"),
              let entries = try? JSONDecoder().decode([Entry].self, from: data) else {
            return MoveCategories()
        }
        let categoriesById = Dictionary(entries.compactMap { entry in
            MoveCategory(rawValue: entry.damage_class_id).map { (entry.id, $0) }
        }, uniquingKeysWith: { first, _ in first })
        return MoveCategories(categoriesById: categoriesById)
    }
}
