import XCTest
@testable import ShinyDex

final class JourneyHandlerTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var journeys: InMemoryJourneyRepository!
    private let evolutions = Evolutions(evolvesFrom: [-1, 0, 1, -1])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"])
        catches = InMemoryCatchRepository()
        journeys = InMemoryJourneyRepository()
    }

    private func logCatch(_ number: Int, isFailed: Bool = false) -> CatchID {
        let caught = Catch(pokemon: pokemon.get(number: number)!, caughtBall: isFailed ? CatchRules.noBall : "poke", caughtDate: Date(), isFailed: isFailed)
        catches.insert(caught)
        catches.save()
        return CatchID(rawValue: caught.id)
    }

    private func getDetails(_ id: JourneyID) -> JourneyDetails? {
        return GetJourneyDetailsHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions)
            .handle(GetJourneyDetailsQuery(journeyId: id))
    }

    private func getLinkable(_ id: JourneyID, _ entry: JourneyEntryID, as role: JourneyCatchRole = .target) -> [CatchSummary] {
        return GetLinkableCatchesHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions)
            .handle(GetLinkableCatchesQuery(journeyId: id, entryId: entry, role: role))
    }

    func test_linkingACatch_ticksTheEntryOff_andShowsItOnTheTimeline() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Grass", pokemonNumbers: [0, 3]))
        let ivysaurCatch = logCatch(1)
        _ = logCatch(0, isFailed: true)
        let entry = getDetails(id)!.entries[0]

        XCTAssertEqual(entry.linkableCatchCount, 1, "Evolution line counts, catches that got away don't")
        XCTAssertEqual(getLinkable(id, entry.id).map { $0.id }, [ivysaurCatch])

        UpdateJourneyHandler(journeyRepository: journeys).handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entry.id, catchId: ivysaurCatch)))

        let linked = getDetails(id)!
        XCTAssertEqual(linked.caughtCount, 1)
        XCTAssertEqual(linked.entries[0].linkedCatch?.pokemonName, "Ivysaur")
        XCTAssertEqual(linked.timeline.map { $0.caught.id }, [ivysaurCatch])
    }

    func test_aCatchCanOnlyBeLinkedOncePerJourney() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Twins", pokemonNumbers: [0, 0]))
        let only = logCatch(0)
        let entries = getDetails(id)!.entries
        UpdateJourneyHandler(journeyRepository: journeys).handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[0].id, catchId: only)))

        XCTAssertEqual(getLinkable(id, entries[0].id).map { $0.id }, [only], "The linked entry still offers its own catch")
        XCTAssertTrue(getLinkable(id, entries[1].id).isEmpty)
    }

    func test_entriesCanBeAddedMovedRemovedAndTheJourneyDeleted() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Team", pokemonNumbers: [0]))
        let update = UpdateJourneyHandler(journeyRepository: journeys)

        update.handle(UpdateJourneyCommand(journeyId: id, change: .addPokemon([3, 2])))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .moveEntry(from: 2, to: 0)))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .removeEntry(getDetails(id)!.entries[1].id)))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .rename("Final team")))

        XCTAssertEqual(getDetails(id)?.entries.map { $0.pokemonName }, ["Venusaur", "Charmander"])
        XCTAssertEqual(GetJourneysHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon).handle(GetJourneysQuery()).map { $0.name }, ["Final team"])

        DeleteJourneyHandler(journeyRepository: journeys).handle(DeleteJourneyCommand(journeyId: id))
        XCTAssertNil(getDetails(id))
    }

    func test_phaseCandidates_areOtherSpecies_includingOnesThatGotAway() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Grass", pokemonNumbers: [0]))
        _ = logCatch(1)
        let fledCharmander = logCatch(3, isFailed: true)
        let entry = getDetails(id)!.entries[0]

        XCTAssertEqual(getLinkable(id, entry.id, as: .phase).map { $0.id }, [fledCharmander], "The entry's own evolution line isn't a phase")
    }

    func test_loggingAPhase_showsItOnTheEntryAndTimeline_withoutTickingTheEntryOff() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Grass", pokemonNumbers: [0, 3]))
        let charmanderPhase = logCatch(3, isFailed: true)
        let entries = getDetails(id)!.entries
        let update = UpdateJourneyHandler(journeyRepository: journeys)

        update.handle(UpdateJourneyCommand(journeyId: id, change: .addPhase(entry: entries[0].id, catchId: charmanderPhase)))

        let logged = getDetails(id)!
        XCTAssertEqual(logged.entries[0].phases.map { $0.id }, [charmanderPhase])
        XCTAssertEqual(logged.phaseCount, 1)
        XCTAssertEqual(logged.caughtCount, 0)
        XCTAssertEqual(logged.timeline, [JourneyTimelineStep(caught: logged.entries[0].phases[0], isPhase: true, entryPokemonName: "Bulbasaur")])
        XCTAssertTrue(getLinkable(id, entries[0].id, as: .phase).isEmpty, "A logged phase isn't offered again")
        XCTAssertEqual(logged.entries[1].linkableCatchCount, 0, "A phase can't also be linked as another entry's catch")

        update.handle(UpdateJourneyCommand(journeyId: id, change: .removePhase(entry: entries[0].id, catchId: charmanderPhase)))

        XCTAssertTrue(getDetails(id)!.entries[0].phases.isEmpty)
        XCTAssertTrue(getDetails(id)!.timeline.isEmpty)
    }
}
