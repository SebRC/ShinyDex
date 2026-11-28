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

    private func makeDay(_ day: Int) -> Date {
        return DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 2, day: day).date!
    }

    private func log(_ number: Int, ball: String, on date: Date) {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository()).handle(LogCatchCommand(number: number, outcome: .caught(ball: ball), date: date))
    }

    private func getSpeciesCatches(_ number: Int) -> [CatchSummary] {
        return GetCatchesHandler(catchRepository: catches, pokemonRepository: pokemon).handle(GetCatchesQuery(scope: .species(number), includingFailed: true))
    }

    func test_logCatch_showsTheLatestBallOnThePokemon() {
        log(bulbasaur, ball: "ultra", on: makeDay(5))
        log(bulbasaur, ball: "poke", on: makeDay(1))

        XCTAssertEqual(getSpeciesCatches(bulbasaur).map { $0.caughtBall }, ["poke", "ultra"], "Oldest first")
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "ultra")
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtDescription, "Caught")
    }

    func test_gotAway_isRecorded_butDoesNotMarkThePokemonCaught() {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository()).handle(LogCatchCommand(number: ivysaur, outcome: .gotAway, date: makeDay(1)))

        XCTAssertEqual(getSpeciesCatches(ivysaur).map { $0.isFailed }, [true])
        XCTAssertEqual(pokemon.get(number: ivysaur)?.caughtBall, "none")
    }

    func test_removeLatestCatch_removesTheNewest_andReportsWhenThereIsNone() {
        let remove = RemoveLatestCatchHandler(catchRepository: catches, deleteCatch: DeleteCatchHandler(catchRepository: catches, pokemonRepository: pokemon))
        log(bulbasaur, ball: "poke", on: makeDay(1))
        log(bulbasaur, ball: "dusk", on: makeDay(9))

        XCTAssertTrue(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "poke")
        XCTAssertTrue(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtDescription, "Not Caught")
        XCTAssertFalse(remove.handle(RemoveLatestCatchCommand(number: bulbasaur)))
    }

    func test_deleteCatch_removesOnlyThatCatch_andKeepsTheLatestBallOnThePokemon() {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        log(bulbasaur, ball: "great", on: makeDay(4))
        log(bulbasaur, ball: "dusk", on: makeDay(9))
        let delete = DeleteCatchHandler(catchRepository: catches, pokemonRepository: pokemon)

        delete.handle(DeleteCatchCommand(catchId: getSpeciesCatches(bulbasaur)[1].id))
        XCTAssertEqual(getSpeciesCatches(bulbasaur).map { $0.caughtBall }, ["poke", "dusk"])
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "dusk")

        delete.handle(DeleteCatchCommand(catchId: getSpeciesCatches(bulbasaur)[1].id))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "poke", "Deleting the newest falls back to the next latest ball")

        delete.handle(DeleteCatchCommand(catchId: getSpeciesCatches(bulbasaur)[0].id))
        XCTAssertTrue(getSpeciesCatches(bulbasaur).isEmpty)
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtDescription, "Not Caught")
    }

    func test_updateCatch_changesTheCatch_andFailsCleanlyWhenTheSaveFails() throws {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        let id = getSpeciesCatches(bulbasaur)[0].id
        let update = UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon)

        try update.handle(UpdateCatchCommand(catchId: id, change: .ball("master")))
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "master")

        catches.failsToSave = true
        XCTAssertThrowsError(try update.handle(UpdateCatchCommand(catchId: id, change: .encounters(500))))
        XCTAssertEqual(getSpeciesCatches(bulbasaur)[0].encounters, 0, "A failed save leaves the stored catch as it was")
        XCTAssertThrowsError(try update.handle(UpdateCatchCommand(catchId: CatchID(rawValue: UUID()), change: .encounters(1))))
    }

    func test_updateCatch_setsAndClearsNicknameGenderNatureAndIVs() throws {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        let id = getSpeciesCatches(bulbasaur)[0].id
        let update = UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon)
        let ivs = IndividualValues().setting(31, for: .speed)

        try update.handle(UpdateCatchCommand(catchId: id, change: .nickname("  Sprout  ")))
        try update.handle(UpdateCatchCommand(catchId: id, change: .gender(.male)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .nature(.jolly)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .ivs(ivs)))

        let updated = getSpeciesCatches(bulbasaur)[0]
        XCTAssertEqual(updated.nickname, "Sprout", "Nicknames are trimmed")
        XCTAssertEqual(updated.gender, .male)
        XCTAssertEqual(updated.nature, .jolly)
        XCTAssertEqual(updated.ivs, ivs)

        try update.handle(UpdateCatchCommand(catchId: id, change: .nickname("   ")))
        try update.handle(UpdateCatchCommand(catchId: id, change: .gender(nil)))
        try update.handle(UpdateCatchCommand(catchId: id, change: .nature(nil)))

        let cleared = getSpeciesCatches(bulbasaur)[0]
        XCTAssertNil(cleared.nickname, "A blank nickname removes it")
        XCTAssertNil(cleared.gender)
        XCTAssertNil(cleared.nature)
    }

    func test_evolveCatch_movesItToTheTarget_andBackClearsTheOrigin() throws {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        let id = getSpeciesCatches(bulbasaur)[0].id
        let evolve = EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon)

        try evolve.handle(EvolveCatchCommand(catchId: id, targetNumber: venusaur))
        XCTAssertTrue(getSpeciesCatches(bulbasaur).isEmpty)
        XCTAssertEqual(getSpeciesCatches(venusaur).first?.evolvedFrom, bulbasaur)
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "none")
        XCTAssertEqual(pokemon.get(number: venusaur)?.caughtBall, "poke")

        try evolve.handle(EvolveCatchCommand(catchId: id, targetNumber: bulbasaur))
        XCTAssertNil(getSpeciesCatches(bulbasaur).first?.evolvedFrom)
    }

    func test_catchDetails_includeEvolutionTargets_positionAndLuck() {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        log(bulbasaur, ball: "great", on: makeDay(2))
        let second = getSpeciesCatches(bulbasaur)[1].id
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
        log(bulbasaur, ball: "poke", on: makeDay(1))
        let id = getSpeciesCatches(bulbasaur)[0].id
        try? UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon).handle(UpdateCatchCommand(catchId: id, change: .encounters(42)))

        let statistics = GetCatchStatisticsHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository(), yearlyGoalRepository: InMemoryYearlyGoalRepository(), dailyEncountersRepository: InMemoryDailyEncountersRepository()).handle(GetCatchStatisticsQuery())

        XCTAssertEqual(statistics.foundCount, 1)
        XCTAssertEqual(statistics.shortestHunts.first?.hunt.pokemonName, "Bulbasaur")
        XCTAssertEqual(statistics.shortestHunts.first?.chanceOfFindingSooner ?? 0, Double.getProbability(encounters: 42, odds: 8192), accuracy: 0.0001)
        XCTAssertEqual(statistics.ballUsage.map { $0.key }, ["poke"])
        XCTAssertEqual(statistics.months.reduce(0) { $0 + $1.foundCount }, 1)
        XCTAssertEqual(statistics.weekdays.reduce(0) { $0 + $1.foundCount }, 1)
        XCTAssertEqual(statistics.luckiestDates, [])
    }

    // MARK: Phases

    private func huntVenusaur(encounters: Int) {
        let hunted = pokemon.get(number: venusaur)!
        hunted.encounters = encounters
        hunted.game = .Platinum
        hunted.huntMethod = .Masuda
        hunted.isShinyCharmActive = true
        pokemon.save(hunted)
    }

    private func setVenusaurEncounters(_ encounters: Int) {
        let hunted = pokemon.get(number: venusaur)!
        hunted.encounters = encounters
        pokemon.save(hunted)
    }

    private func logPhase(found number: Int, outcome: LogCatchCommand.Outcome = .caught(ball: "dive")) {
        LogPhaseHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository())
            .handle(LogPhaseCommand(huntedNumber: venusaur, foundNumber: number, outcome: outcome, date: makeDay(3)))
    }

    private func getPhases(_ source: GetPhasesQuery.Source) -> PhaseList? {
        return GetPhasesHandler(catchRepository: catches, pokemonRepository: pokemon).handle(GetPhasesQuery(source: source))
    }

    func test_logPhase_logsTheOtherShinyWithTheHuntsSettings_andTheEncountersSinceTheLastPhase() {
        huntVenusaur(encounters: 300)
        logPhase(found: bulbasaur)
        setVenusaurEncounters(750)
        logPhase(found: ivysaur, outcome: .gotAway)

        let bulbasaurPhase = catches.getAll(number: bulbasaur).first!
        let ivysaurPhase = catches.getAll(number: ivysaur).first!
        XCTAssertEqual(bulbasaurPhase.encounters, 300)
        XCTAssertEqual(bulbasaurPhase.game, .Platinum)
        XCTAssertEqual(bulbasaurPhase.huntMethod, .Masuda)
        XCTAssertTrue(bulbasaurPhase.isShinyCharmActive)
        XCTAssertEqual(bulbasaurPhase.caughtBall, "dive")
        XCTAssertEqual(ivysaurPhase.encounters, 450)
        XCTAssertTrue(ivysaurPhase.isFailed)
        XCTAssertEqual(pokemon.get(number: venusaur)?.phases, [HuntPhase(catchId: bulbasaurPhase.id, encounters: 300), HuntPhase(catchId: ivysaurPhase.id, encounters: 750)])
        XCTAssertEqual(pokemon.get(number: bulbasaur)?.caughtBall, "dive")
    }

    func test_huntPhases_listEachPhase_andTheEncountersSinceTheLast() throws {
        huntVenusaur(encounters: 300)
        logPhase(found: bulbasaur)
        setVenusaurEncounters(1000)

        let list = try XCTUnwrap(getPhases(.hunt(number: venusaur)))

        XCTAssertEqual(list.phases.map { $0.caught.number }, [bulbasaur])
        XCTAssertEqual(list.phases.map { $0.foundAt }, [300])
        XCTAssertEqual(list.phases.map { $0.encounters }, [300])
        XCTAssertEqual(list.encountersAfterPhases, 700)
        XCTAssertTrue(list.isHunt)
        XCTAssertEqual(GetPokemonDetailsHandler(pokemonRepository: pokemon, catchRepository: catches, odds: OddsService(), probability: ProbabilityService())
            .handle(GetPokemonDetailsQuery(number: venusaur))?.encountersThisPhase, 700)
    }

    func test_loggingTheTarget_movesItsPhasesOntoTheCatch() throws {
        huntVenusaur(encounters: 300)
        logPhase(found: bulbasaur)
        setVenusaurEncounters(1000)
        log(venusaur, ball: "ultra", on: makeDay(4))

        let target = try XCTUnwrap(catches.getAll(number: venusaur).first)
        let phase = try XCTUnwrap(catches.getAll(number: bulbasaur).first)
        XCTAssertEqual(target.phaseCatchIds, [phase.id])
        XCTAssertEqual(target.encounters, 1000)
        XCTAssertEqual(pokemon.get(number: venusaur)?.phases, [])
        let list = try XCTUnwrap(getPhases(.caught(CatchID(rawValue: target.id))))
        XCTAssertEqual(list.phases.map { $0.encounters }, [300])
        XCTAssertEqual(list.encountersAfterPhases, 700)
        XCTAssertFalse(list.isHunt)
        XCTAssertEqual(GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: Evolutions(evolvesFrom: [-1, 0, 1]))
            .handle(GetCatchDetailsQuery(catchId: CatchID(rawValue: target.id)))?.phaseCount, 1)
    }

    func test_unlinkingAPhase_keepsTheShiny_andResettingTheCounterClearsPhases() {
        huntVenusaur(encounters: 300)
        logPhase(found: bulbasaur)
        logPhase(found: ivysaur)
        let bulbasaurPhase = catches.getAll(number: bulbasaur).first!

        UnlinkPhaseHandler(pokemonRepository: pokemon).handle(UnlinkPhaseCommand(huntedNumber: venusaur, catchId: CatchID(rawValue: bulbasaurPhase.id)))

        XCTAssertEqual(pokemon.get(number: venusaur)?.phases.count, 1)
        XCTAssertEqual(catches.getAll(number: bulbasaur).count, 1)

        ChangeEncountersHandler(pokemonRepository: pokemon, catchRepository: catches, ledgerRepository: InMemoryEncounterLedgerRepository(),
                                dailyEncountersRepository: InMemoryDailyEncountersRepository(), odds: OddsService())
            .handle(ChangeEncountersCommand(number: venusaur, change: .set(0)))

        XCTAssertEqual(pokemon.get(number: venusaur)?.phases, [])
        XCTAssertEqual(catches.getAll().count, 2)
    }

    func test_pastPhases_canBeLinkedToAFinishedCatch_onceEach() throws {
        log(bulbasaur, ball: "poke", on: makeDay(1))
        log(ivysaur, ball: "great", on: makeDay(2))
        log(venusaur, ball: "ultra", on: makeDay(3))
        let target = CatchID(rawValue: catches.getAll(number: venusaur).first!.id)
        let bulbasaurId = CatchID(rawValue: catches.getAll(number: bulbasaur).first!.id)
        let ivysaurId = CatchID(rawValue: catches.getAll(number: ivysaur).first!.id)
        let change = ChangeCatchPhasesHandler(catchRepository: catches, pokemonRepository: pokemon)
        let candidates = { GetPhaseCandidatesHandler(catchRepository: self.catches, pokemonRepository: self.pokemon).handle(GetPhaseCandidatesQuery(catchId: target)).map { $0.id } }

        XCTAssertEqual(candidates(), [ivysaurId, bulbasaurId], "Newest first, leaving out the target itself")

        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .link(bulbasaurId)))
        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .link(bulbasaurId)))
        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .link(target)))

        XCTAssertEqual(catches.get(id: target.rawValue)?.phaseCatchIds, [bulbasaurId.rawValue])
        XCTAssertEqual(candidates(), [ivysaurId])
        XCTAssertEqual(getPhases(.caught(target))?.phases.map { $0.caught.id }, [bulbasaurId])

        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .unlink(bulbasaurId)))

        XCTAssertEqual(catches.get(id: target.rawValue)?.phaseCatchIds, [])
        XCTAssertEqual(catches.getAll().count, 3)
    }

    func test_linkedPhases_areNumberedByCatchDate_notByWhenTheyWereLinked() throws {
        log(bulbasaur, ball: "poke", on: makeDay(5))
        log(ivysaur, ball: "great", on: makeDay(2))
        log(venusaur, ball: "ultra", on: makeDay(9))
        let target = CatchID(rawValue: catches.getAll(number: venusaur).first!.id)
        let change = ChangeCatchPhasesHandler(catchRepository: catches, pokemonRepository: pokemon)
        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .link(CatchID(rawValue: catches.getAll(number: bulbasaur).first!.id))))
        change.handle(ChangeCatchPhasesCommand(catchId: target, change: .link(CatchID(rawValue: catches.getAll(number: ivysaur).first!.id))))

        let list = try XCTUnwrap(getPhases(.caught(target)))

        XCTAssertEqual(list.phases.map { $0.caught.number }, [ivysaur, bulbasaur])
    }

    func test_phaseCandidates_leaveOutShiniesAlreadyLinkedToARunningHunt() {
        huntVenusaur(encounters: 300)
        logPhase(found: bulbasaur)
        log(ivysaur, ball: "great", on: makeDay(2))
        let ivysaurCatch = CatchID(rawValue: catches.getAll(number: ivysaur).first!.id)

        let candidates = GetPhaseCandidatesHandler(catchRepository: catches, pokemonRepository: pokemon).handle(GetPhaseCandidatesQuery(catchId: ivysaurCatch))

        XCTAssertEqual(candidates.map { $0.number }, [])
    }

    func test_huntPhases_encodeAndDecode() {
        let phases = [HuntPhase(catchId: UUID(), encounters: 12), HuntPhase(catchId: UUID(), encounters: 4096)]

        XCTAssertEqual(HuntPhase.decode(HuntPhase.encode(phases)), phases)
        XCTAssertNil(HuntPhase.encode([]))
        XCTAssertEqual(HuntPhase.decode("not-a-phase,also:bad"), [])
    }
}
