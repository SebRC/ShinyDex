import Foundation

struct BingoEntry: Equatable {
    let number: Int
    let formId: String?
}

struct BingoTemplate: Equatable {
    let id: String
    let name: String
    let entries: [BingoEntry]
}

struct BingoTemplates {
    let templates: [BingoTemplate]

    init(templates: [BingoTemplate] = []) {
        self.templates = templates
    }

    func find(id: String) -> BingoTemplate? {
        return templates.first { $0.id == id }
    }

    static func pickEntries<Generator: RandomNumberGenerator>(from pool: [BingoEntry], count: Int, using generator: inout Generator) -> [BingoEntry] {
        return Array(pool.shuffled(using: &generator).prefix(count))
    }
}
