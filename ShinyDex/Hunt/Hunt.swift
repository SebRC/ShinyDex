import Foundation

class Hunt {
    let id: UUID
    var name: String
    var indexes: [Int]
    var pokemon: [Pokemon]
    var totalEncounters: Int
    var priority: Int
    var isCollapsed: Bool

    init(id: UUID = UUID(), name: String, indexes: [Int], priority: Int, isCollapsed: Bool) {
        self.id = id
        self.name = name
        self.indexes = indexes
        self.priority = priority
        self.isCollapsed = isCollapsed
        self.pokemon = [Pokemon]()
        self.totalEncounters = 0
    }

    convenience init(name: String, pokemon: [Pokemon], priority: Int) {
        self.init(name: name, indexes: [Int](), priority: priority, isCollapsed: false)
        self.pokemon = pokemon
    }
}
