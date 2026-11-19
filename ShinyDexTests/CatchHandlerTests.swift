import XCTest
@testable import ShinyDex

final class CatchHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let bulbasaur = 0, ivysaur = 1, venusaur = 2

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur"])
        catches = InMemoryCatchRepository()
    }

    private func day(_ day: Int) -> Date {
        return DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 2, day: day).date!
    }

    private func log(_ number: Int, ball: String, on date: Date) {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(LogCatchCommand(number: number, outcome: .caught(ball: ball), date: date))
    }

    private func speciesCatches(_ number: Int) -> [CatchSummary] {
        return GetCatchesHandler(catchRepository: catches, pokemonRepository: pokemon).handle(GetCatchesQuery(scope: .species(number), includingFailed: true))
    }

    func test_logCatch_showsTheLatestBallOnThePokemon() {
        log(bulbasaur, ball: "ultra", on: day(5))
        log(bulbasaur, ball: "poke", on: day(1))

        XCTAssertEqual(speciesCatches(bulbasaur).map { $0.caughtBall }, ["poke", "ultra"], "Oldest first")
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "ultra")
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtDescription, "Caught")
    }

    func test_gotAway_isRecorded_butDoesNotMarkThePokemonCaught() {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(LogCatchCommand(number: ivysaur, outcome: .gotAway, date: day(1)))

        XCTAssertEqual(speciesCatches(ivysaur).map { $0.isFailed }, [true])
        XCTAssertEqual(pokemon.get(number: ivysaur)?.caughtBall, "none")
    }

    func test_removeLatestCatch_removesTheNewest_andReportsWhenThereIsNone() {
        let remove = RemoveLatestCatchHandler(catchRepository: catches, deleteCatch: DeleteCatchHandler(catchRepository: catches, pokemonRepository: pokemon))
        log(bulbasaur, ball: "poke", on: day(1))
        log(bulbasaur, ball: "dusk", on: day(9))

        XCTAssertTrue(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "poke")
        XCTAssertTrue(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtDescription, "Not Caught")
        XCTAssertFalse(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
    }

    func test_updateCatch_changesTheCatch_andFailsCleanlyWhenTheSaveFails() throws {
        log(bulbasaur, ball: "poke", on: day(1))
        let id = speciesCatches(bulbasaur)[0].id
        let update = UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon)

        try update.handle(UpdateCatchCommand(catchId: id, change: .ball("master")))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "master")

        catches.failsToSave = true
        XCTAssertThrowsError(try update.handle(UpdateCatchCommand(catchId: id, change: .encounters(500))))
        XCTAssertEqual(speciesCatches(bulbasaur)[0].encounters, 0, "A failed save leaves the stored catch as it was")
        XCTAssertThrowsError(try update.handle(UpdateCatchCommand(catchId: CatchID(rawValue: UUID()), change: .encounters(1))))
    }

    func test_updateCatch_setsAndClearsNicknameGenderNatureAndIVs() throws {
        log(bulbasaur, ball: "poke", on: day(1))
        let id = speciesCatches(bulbasaur)[0].id
        let update = UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon)
        let ivs = IndividualValues().setting(31, for: .speed)

        try update.handle(UpdateCatchCommand(catchId: id, change: .nickname("  Sprout  ")))
        try update.handle(UpdateCatchCommand(catchId: id, change: .gender(.male)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .nature(.jolly)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .ivs(ivs)))

        let updated = speciesCatches(bulbasaur)[0]
        XCTAssertEqual(updated.nickname, "Sprout", "Nicknames are trimmed")
        XCTAssertEqual(updated.gender, .male)
        XCTAssertEqual(updated.nature, .jolly)
        XCTAssertEqual(updated.ivs, ivs)

        try update.handle(UpdateCatchCommand(catchId: id, change: .nickname("   ")))
        try update.handle(UpdateCatchCommand(catchId: id, change: .gender(nil)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .nature(nil)))

        let cleared = speciesCatches(bulbasaur)[0]
        XCTAssertNil(cleared.nickname, "A blank nickname removes it")
        XCTAssertNil(cleared.gender)
        XCTAssertNil(cleared.nature)
    }

    func test_evolveCatch_movesItToTheTarget_andBackClearsTheOrigin() throws {
        log(bulbasaur, ball: "poke", on: day(1))
        let id = speciesCatches(bulbasaur)[0].id
        let evolve = EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon)

        try evolve.handle(EvolveCatchCommand(catchId: id, targetNumber: venusaur))
        XCTAssertTrue(speciesCatches(bulbasaur).isEmpty)
        XCTAssertEqual(speciesCatches(venusaur).first?.evolvedFrom, bulbasaur)
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "none")
        XCTAssertEqual(pokemon.get(number: venusaur)?.caughtBall, "poke")

        try evolve.handle(EvolveCatchCommand(catchId: id, targetNumber: bulbasaur))
        XCTAssertNil(speciesCatches(bulbasaur).first?.evolvedFrom)
    }

    func test_catchDetails_includeEvolutionTargets_positionAndLuck() {
        log(bulbasaur, ball: "poke", on: day(1))
        log(bulbasaur, ball: "great", on: day(2))
        let second = speciesCatches(bulbasaur)[1].id
        try? UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(UpdateCatchCommand(catchId: second, change: .encounters(8192)))
        let evolutions = Evolutions(evolvesFrom: [-1, 0, 1])

        let details = GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions).handle(GetCatchDetailsQuery(catchId: second))

        XCTAssertEqual(details?.summary.pokemonName, "Bulbasaur")
        XCTAssertEqual(details?.evolutionTargets.map { $0.name }, ["Ivysaur", "Venusaur"])
        XCTAssertEqual(details?.position, 1)
        XCTAssertEqual(details?.speciesCatchCount, 2)
        XCTAssertEqual(details?.odds, 8192)
        XCTAssertEqual(details?.chanceOfFindingSooner ?? 0, 63.2, accuracy: 0.1)
    }

    func test_statistics_mapRecordsToSummaries() {
        log(bulbasaur, ball: "poke", on: day(1))
        let id = speciesCatches(bulbasaur)[0].id
        try? UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(UpdateCatchCommand(catchId: id, change: .encounters(42)))

        let statistics = GetCatchStatisticsHandler(catchRepository: catches, pokemonRepository: pokemon).handle(GetCatchStatisticsQuery())

        XCTAssertEqual(statistics.foundCount, 1)
        XCTAssertEqual(statistics.fastestCatch?.pokemonName, "Bulbasaur")
        XCTAssertEqual(statistics.ballUsage.map { $0.key }, ["poke"])
        XCTAssertEqual(statistics.months.reduce(0) { $0 + $1.foundCount }, 1)
        XCTAssertEqual(statistics.weekdays.reduce(0) { $0 + $1.foundCount }, 1)
        XCTAssertEqual(statistics.luckiestDates, [])
    }
}
