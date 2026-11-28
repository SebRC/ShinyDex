import Foundation

struct MoveTyping {
    private let typesById: [Int: PokemonType]

    init(typesById: [Int: PokemonType] = [:]) {
        self.typesById = typesById
    }

    func findType(of moveId: Int) -> PokemonType? {
        return typesById[moveId]
    }
}
