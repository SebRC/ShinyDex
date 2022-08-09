import Foundation

class Game {
    private(set) var title: String
    private(set) var coverPokemon: String
    private(set) var generation: Int
    private(set) var availableMethods: [HuntMethod]
    private(set) var isShinyCharmAvailable: Bool
    
    init(game: Games, coverPokemon: String, generation: Int, availableMethods: [HuntMethod], isShinyCharmAvailable: Bool) {
        self.title = game.rawValue
        self.coverPokemon = coverPokemon
        self.generation = generation
        self.availableMethods = availableMethods
        self.isShinyCharmAvailable = isShinyCharmAvailable
    }
}
