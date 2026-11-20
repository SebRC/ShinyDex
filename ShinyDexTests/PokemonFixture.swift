@testable import ShinyDex

final class PokemonFixture {
    var name = "Placeholder"
    var number = -1
    var encounters = -1
    var generation = 1
    var game = Games.Red
    var huntMethod = HuntMethod.Encounters
    var isShinyCharmActive = false

    var settings: HuntSettings {
        return HuntSettings(game: game, generation: generation, huntMethod: huntMethod, isShinyCharmActive: isShinyCharmActive)
    }

    func makeDetails(chainThreshold: Int = 0, probability: Double = 0) -> PokemonDetails {
        return PokemonDetails(number: number, name: name, encounters: encounters, increment: 1, settings: settings, shinyOdds: 8192,
                              chainThreshold: chainThreshold, probability: probability, caughtBall: "none", catchCount: 0, isBeingHunted: false)
    }
}
