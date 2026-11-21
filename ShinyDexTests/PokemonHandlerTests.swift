import XCTest
@testable import ShinyDex

final class PokemonHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur"])
        catches = InMemoryCatchRepository()
    }

    private func getDetails(_ number: Int) -> PokemonDetails? {
        return GetPokemonDetailsHandler(pokemonRepository: pokemon, catchRepository: catches, odds: OddsService(), probability: ProbabilityService())
            .handle(GetPokemonDetailsQuery(number: number))
    }

    func test_changeEncounters_incrementsByTheStoredIncrement_andNeverGoesBelowZero() {
        SetIncrementHandler(pokemonRepository: pokemon).handle(SetIncrementCommand(number: 0, increment: 5))
        let change = ChangeEncountersHandler(pokemonRepository: pokemon, catchRepository: InMemoryCatchRepository(), ledgerRepository: InMemoryEncounterLedgerRepository(), dailyEncountersRepository: InMemoryDailyEncountersRepository(), odds: OddsService())

        change.handle(ChangeEncountersCommand(number: 0, change: .increment))
        change.handle(ChangeEncountersCommand(number: 0, change: .increment))
        change.handle(ChangeEncountersCommand(number: 0, change: .decrement))
        XCTAssertEqual(getDetails(0)?.encounters, 9)

        change.handle(ChangeEncountersCommand(number: 0, change: .set(0)))
        change.handle(ChangeEncountersCommand(number: 0, change: .decrement))
        change.handle(ChangeEncountersCommand(number: 1, change: .set(-4)))
        XCTAssertEqual(getDetails(0)?.encounters, 0)
        XCTAssertEqual(getDetails(1)?.encounters, 0)
    }

    func test_details_countOnlyCatchesThatWereCaught_andCalculateOdds() {
        let bulbasaur = pokemon.get(number: 0)!
        catches.insert(Catch(pokemon: bulbasaur, caughtBall: "poke", caughtDate: nil))
        catches.insert(Catch(pokemon: bulbasaur, caughtBall: CatchRules.noBall, caughtDate: nil, isFailed: true))
        catches.save()

        let result = getDetails(0)

        XCTAssertEqual(result?.catchCount, 1)
        XCTAssertEqual(result?.shinyOdds, 8192)
        XCTAssertEqual(result?.usesChain, false)
        XCTAssertEqual(result?.chain, 0)
        XCTAssertNil(getDetails(99))
    }

    func test_previewSelectingAGame_setsItsGeneration_andDropsWhatTheGameLacks() {
        let preview = PreviewHuntSettingsHandler(odds: OddsService())
        let masudaWithCharm = HuntSettings(game: .Sword, generation: 8, huntMethod: .Masuda, isShinyCharmActive: true)

        let gold = preview.handle(PreviewHuntSettingsQuery(settings: masudaWithCharm, chain: 0, selectingGame: .Gold))

        XCTAssertEqual(gold.settings, HuntSettings(game: .Gold, generation: 2, huntMethod: .Encounters, isShinyCharmActive: false))
        XCTAssertEqual(gold.shinyOdds, 8192)
        XCTAssertEqual(preview.handle(PreviewHuntSettingsQuery(settings: masudaWithCharm, chain: 0)).shinyOdds, 512)
    }

    func test_saveHuntSettings_normalisesAndStoresTheOdds() {
        SaveHuntSettingsHandler(pokemonRepository: pokemon, odds: OddsService())
            .handle(SaveHuntSettingsCommand(number: 2, settings: HuntSettings(game: .Gold, generation: 2, huntMethod: .Encounters, isShinyCharmActive: true)))

        let stored = pokemon.get(number: 2)!
        XCTAssertEqual(stored.game, .Gold)
        XCTAssertEqual(stored.generation, 2)
        XCTAssertFalse(stored.isShinyCharmActive, "Gold has no Shiny Charm")
        XCTAssertEqual(stored.shinyOdds, 8192)
    }

    func test_applyHuntSettingsToAll_changesEveryPokemon() {
        ApplyHuntSettingsToAllHandler(pokemonRepository: pokemon, odds: OddsService())
            .handle(ApplyHuntSettingsToAllCommand(settings: HuntSettings(game: .Scarlet, generation: 9, huntMethod: .Encounters, isShinyCharmActive: true)))

        for stored in pokemon.getAll() {
            XCTAssertEqual(stored.game, .Scarlet)
            XCTAssertTrue(stored.isShinyCharmActive)
            XCTAssertEqual(stored.shinyOdds, 1365)
        }
    }

    func test_pokedex_listsTheRegionWithCatchCounts() {
        let ivysaur = pokemon.get(number: 1)!
        catches.insert(Catch(pokemon: ivysaur, caughtBall: "great", caughtDate: nil))
        catches.save()
        let handler = GetPokedexHandler(pokemonRepository: pokemon, catchRepository: catches)

        let kanto = handler.handle(GetPokedexQuery(region: 0))

        XCTAssertEqual(kanto.entries.map { $0.name }, ["Bulbasaur", "Ivysaur", "Venusaur"])
        XCTAssertEqual(kanto.entries.map { $0.catchCount }, [0, 1, 0])
    }

    func test_pokedex_filtersByStatus_andKeepsTheRegionTotals() {
        catches.insert(Catch(pokemon: pokemon.get(number: 1)!, caughtBall: "great", caughtDate: nil))
        catches.insert(Catch(pokemon: pokemon.get(number: 2)!, caughtBall: "none", caughtDate: nil, isFailed: true))
        catches.save()
        let venusaur = pokemon.get(number: 2)!
        venusaur.isBeingHunted = true
        pokemon.save(venusaur)
        let handler = GetPokedexHandler(pokemonRepository: pokemon, catchRepository: catches)

        func names(_ filter: PokedexFilter) -> [String] {
            return handler.handle(GetPokedexQuery(region: 0, filter: filter)).entries.map { $0.name }
        }

        XCTAssertEqual(names(.all), ["Bulbasaur", "Ivysaur", "Venusaur"])
        XCTAssertEqual(names(.notCaught), ["Bulbasaur", "Venusaur"], "One that got away doesn't count as caught")
        XCTAssertEqual(names(.caught), ["Ivysaur"])
        XCTAssertEqual(names(.inHunt), ["Venusaur"])
        let caughtOnly = handler.handle(GetPokedexQuery(region: 0, filter: .caught))
        XCTAssertEqual(caughtOnly.caughtCount, 1)
        XCTAssertEqual(caughtOnly.totalCount, 3)
    }
}
