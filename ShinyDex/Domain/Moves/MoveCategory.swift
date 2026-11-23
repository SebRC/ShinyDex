import Foundation

enum MoveCategory: Int {
    case status = 1
    case physical = 2
    case special = 3
}

struct MoveCategories {
    private let categoriesById: [Int: MoveCategory]

    init(categoriesById: [Int: MoveCategory] = [:]) {
        self.categoriesById = categoriesById
    }

    func findCategory(of moveId: Int) -> MoveCategory? {
        return categoriesById[moveId]
    }
}
