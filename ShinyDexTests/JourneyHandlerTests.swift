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

    private func logCatch(_ number: Int, in game: Games, on day: Int, isFailed: Bool = false, encounters: Int = 100) -> CatchID {
        let caught = Catch(number: number, caughtBall: isFailed ? CatchRules.noBall : "poke", game: game, huntMethod: .Encounters, encounters: encounters,
                           isShinyCharmActive: false, caughtDate: Date(timeIntervalSince1970: Double(day) * 86_400), isFailed: isFailed)
        catches.insert(caught)
        catches.save()
        return CatchID(rawValue: caught.id)
    }

    private func getPlayback(_ id: JourneyID, store: KeyValueStore = InMemoryKeyValueStore()) -> JourneyPlayback? {
        return GetJourneyPlaybackHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, keyValueStore: store)
            .handle(GetJourneyPlaybackQuery(journeyId: id))
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

    func test_phaseCandidates_includeTheEntrysOwnLine_andOtherSpeciesThatGotAway_butNotItsTarget() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Grass", pokemonNumbers: [0]))
        let target = logCatch(0)
        let unwantedBulbasaur = logCatch(0)
        let ivysaur = logCatch(1)
        let fledCharmander = logCatch(3, isFailed: true)
        let entry = getDetails(id)!.entries[0]
        UpdateJourneyHandler(journeyRepository: journeys).handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entry.id, catchId: target)))

        XCTAssertEqual(Set(getLinkable(id, entry.id, as: .phase).map { $0.id }), [unwantedBulbasaur, ivysaur, fledCharmander])
    }

    func test_anotherEntrysCatch_isOfferedAsAPhase() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Team", pokemonNumbers: [0, 3]))
        let entries = getDetails(id)!.entries
        let charmander = logCatch(3)
        let update = UpdateJourneyHandler(journeyRepository: journeys)
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[1].id, catchId: charmander)))

        XCTAssertEqual(getLinkable(id, entries[0].id, as: .phase).map { $0.id }, [charmander])

        update.handle(UpdateJourneyCommand(journeyId: id, change: .addPhase(entry: entries[0].id, catchId: charmander)))
        let details = getDetails(id)!

        XCTAssertEqual(details.entries[0].phases.map { $0.id }, [charmander])
        XCTAssertEqual(details.entries[1].linkedCatch?.id, charmander)
        XCTAssertEqual(details.timeline.count, 1)
        XCTAssertEqual(details.timeline.first?.alsoPhaseWhileHunting, "Bulbasaur")
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

    func test_playback_bringsAlongTheGen3And4Shinies_inTheOrderTheyWereFound() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Kanto", pokemonNumbers: [0, 3, 2]))
        let entries = getDetails(id)!.entries
        let charmander = logCatch(3, in: .Heartgold, on: 2)
        let bulbasaurPhase = logCatch(0, in: .Platinum, on: 1)
        let venusaurFromRed = logCatch(2, in: .Red, on: 3)
        let gotAway = logCatch(0, in: .SoulSilver, on: 4, isFailed: true)
        let update = UpdateJourneyHandler(journeyRepository: journeys)
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[1].id, catchId: charmander)))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[2].id, catchId: venusaurFromRed)))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .addPhase(entry: entries[1].id, catchId: bulbasaurPhase)))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .addPhase(entry: entries[0].id, catchId: gotAway)))

        let playback = getPlayback(id)

        XCTAssertEqual(playback?.companions.map { $0.id }, [bulbasaurPhase, charmander], "Gen 1 catches and ones that got away stay home")
        XCTAssertEqual(playback?.games, [.Platinum, .Heartgold], "Ties go to the game found in first")
        XCTAssertEqual(playback?.journeyName, "Kanto")
    }

    func test_playback_isUnavailable_withoutAGen3Or4Shiny() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Modern", pokemonNumbers: [0]))
        let scarletCatch = logCatch(0, in: .Scarlet, on: 1)
        UpdateJourneyHandler(journeyRepository: journeys).handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: getDetails(id)!.entries[0].id, catchId: scarletCatch)))

        XCTAssertNil(getPlayback(id))
    }

    func test_playback_leadsWithTheGameMostShiniesCameFrom_andRemembersThePlayer() {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Hoenn", pokemonNumbers: [0, 1, 3]))
        let entries = getDetails(id)!.entries
        let update = UpdateJourneyHandler(journeyRepository: journeys)
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[0].id, catchId: logCatch(0, in: .Ruby, on: 1))))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[1].id, catchId: logCatch(1, in: .Emerald, on: 2))))
        update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entries[2].id, catchId: logCatch(3, in: .Emerald, on: 3))))
        let store = InMemoryKeyValueStore()

        XCTAssertEqual(getPlayback(id, store: store)?.games, [.Emerald, .Ruby])
        XCTAssertEqual(getPlayback(id, store: store)?.isPlayerFemale, false)

        ChoosePlaybackPlayerHandler(keyValueStore: store).handle(ChoosePlaybackPlayerCommand(isFemale: true))

        XCTAssertEqual(getPlayback(id, store: store)?.isPlayerFemale, true)
    }

    func test_playback_totalsTheEncounters_andPicksTheLuckiestFind() throws {
        let id = CreateJourneyHandler(journeyRepository: journeys).handle(CreateJourneyCommand(name: "Johto", pokemonNumbers: [0, 1, 3]))
        let entries = getDetails(id)!.entries
        let update = UpdateJourneyHandler(journeyRepository: journeys)
        let slow = logCatch(0, in: .Heartgold, on: 1, encounters: 9000)
        let lucky = logCatch(1, in: .Heartgold, on: 2, encounters: 40)
        let middling = logCatch(3, in: .Heartgold, on: 3, encounters: 3000)
        for (entry, caught) in zip(entries, [slow, lucky, middling]) {
            update.handle(UpdateJourneyCommand(journeyId: id, change: .link(entry: entry.id, catchId: caught)))
        }

        let playback = try XCTUnwrap(getPlayback(id))

        XCTAssertEqual(playback.totalEncounters, 12_040)
        XCTAssertEqual(playback.luckiestFind?.catchId, lucky)
        XCTAssertEqual(playback.luckiestFind?.chanceOfFindingSooner ?? 0, Double.getProbability(encounters: 40, odds: 8192), accuracy: 0.0001)
    }
}
