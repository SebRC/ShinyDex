import Foundation

class Game {
    var title: String
    var coverPokemon: String
    var generation: Int
    var availableMethods: [HuntMethod]
    var isShinyCharmAvailable: Bool
    
    init(title: String, coverPokemon: String, generation: Int, availableMethods: [HuntMethod], isShinyCharmAvailable: Bool) {
        self.title = title
        self.coverPokemon = coverPokemon
        self.generation = generation
        self.availableMethods = availableMethods
        self.isShinyCharmAvailable = isShinyCharmAvailable
    }
}
