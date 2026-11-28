import XCTest
@testable import ShinyDex

final class HuntSuggestionTests: XCTestCase {
    private let base = 0, evolved = 1, legendary = 2, tepig = 497
    private let odds = OddsService()
    private var catches: InMemoryCatchRepository!
    private var pokemon: InMemoryPokemonRepository!
    private var journeys: InMemoryJourneyRepository!
    private var store: InMemoryKeyValueStore!

    override func setUp() {
        catches = InMemoryCatchRepository()
        pokemon = InMemoryPokemonRepository(names: ["Base", "Evolved", "Legend"])
        journeys = InMemoryJourneyRepository()
        store = InMemoryKeyValueStore()
    }

    private func makeRow(_ area: String, method: String = "Grass or cave", rate: Int = 20, isShinyLocked: Bool = false) -> EncounterLocation {
        return EncounterLocation(area: area, method: method, minimumLevel: 5, maximumLevel: 7, ratePercent: rate, condition: nil, isShinyLocked: isShinyLocked)
    }

    private func makeSuggester(_ locationsByGame: [Games: [Int: [EncounterLocation]]], shinyLockedIn lockedGame: Games? = nil) -> HuntSuggester {
        let profile = { (rate: Int) in SpeciesCatchProfiles(standard: CatchProfile(catchRate: rate, types: [], weightInHectograms: 10), profilesByFormId: [:]) }
        let platinumWithoutLegendary = GameAvailability.GameData(catchable: [base, evolved], tradeOnly: [], isApproximate: false)
        var dataByGame = [Games.Platinum: platinumWithoutLegendary]
        if let lockedGame = lockedGame {
            dataByGame[lockedGame] = GameAvailability.GameData(catchable: [base, evolved], shinyLocked: [legendary], tradeOnly: [], isApproximate: false)
        }
        return HuntSuggester(locations: PokemonLocations(locationsByGame: locationsByGame), availability: GameAvailability(dataByGame: dataByGame),
                             evolutions: Evolutions(evolvesFrom: [-1, 0, -1]),
                             catchData: PokemonCatchData(profilesByNumber: [base: profile(45), evolved: profile(45), legendary: profile(3)]), odds: odds)
    }

    private func calculateBestOdds(_ method: HuntMethod, in game: Games) -> Int {
        let configuration = HuntConfiguration(game: game, generation: GamesList.games[game]!.generation, huntMethod: method, isShinyCharmActive: true).normalized()
        return odds.getShinyOdds(configuration: configuration, chain: configuration.chainForBestOdds)
    }

    // MARK: Suggester

    func test_picksTheBestOddsMethodInAPreferredGame() {
        let suggester = makeSuggester([.Diamond: [base: [makeRow("Route 201", rate: 30), makeRow("Route 202", rate: 10)]]])

        let suggestion = suggester.suggest(for: base, preferring: [.Diamond])!

        let radar = calculateBestOdds(.Pokeradar, in: .Diamond)
        let masuda = calculateBestOdds(.Masuda, in: .Diamond)
        XCTAssertEqual(suggestion.game, .Diamond)
        XCTAssertEqual(suggestion.method, radar < masuda ? .Pokeradar : .Masuda)
        XCTAssertEqual(suggestion.odds, min(radar, masuda))
    }

    func test_suggestsTheBestAreaForAWildMethod() {
        let suggester = makeSuggester([.Sun: [base: [makeRow("Route 1", method: "SOS call", rate: 10), makeRow("Route 3", method: "SOS call", rate: 40)]]])

        let suggestion = suggester.suggest(for: base, preferring: [.Sun])!

        XCTAssertEqual(suggestion.method, .SosChaining)
        XCTAssertEqual(suggestion.area, "Route 3")
    }

    func test_huntsThePreEvolution_whenOnlyItAppearsInTheGame() {
        let suggester = makeSuggester([.Sun: [base: [makeRow("Route 1", method: "SOS call")]]])

        let suggestion = suggester.suggest(for: evolved, preferring: [.Sun])!

        XCTAssertEqual(suggestion.target, base)
    }

    func test_neverSuggestsBreedingALegendary() {
        let suggester = makeSuggester([.Diamond: [legendary: [makeRow("Spear Pillar", method: "Static encounter", rate: 0)]]])

        let suggestion = suggester.suggest(for: legendary, preferring: [.Diamond])!

        XCTAssertEqual(suggestion.method, .Encounters)
        XCTAssertEqual(suggestion.area, "Spear Pillar")
    }

    func test_suggestsMasuda_inAGameWithoutLocationData() {
        let suggestion = makeSuggester([:]).suggest(for: evolved, preferring: [.Scarlet])!

        XCTAssertEqual(suggestion.game, .Scarlet)
        XCTAssertEqual(suggestion.method, .Masuda)
        XCTAssertEqual(suggestion.target, base)
    }

    func test_fullOddsSticksToPlainEncountersInTheMostUsedGame() {
        let suggester = makeSuggester([.Diamond: [base: [makeRow("Route 201")]], .Sun: [base: [makeRow("Route 1", method: "SOS call")]]])

        let suggestion = suggester.suggest(for: base, preferring: [.Diamond, .Sun], mode: .fullOdds)!

        XCTAssertEqual(suggestion.game, .Diamond)
        XCTAssertEqual(suggestion.method, .Encounters)
        XCTAssertEqual(suggestion.odds, 8192)
        XCTAssertEqual(suggestion.area, "Route 201")
    }

    func test_fullOddsLeavesOutTheShinyCharm() {
        let suggestion = makeSuggester([:]).suggest(for: base, preferring: [.Scarlet], mode: .fullOdds)!

        XCTAssertEqual(suggestion.method, .Encounters)
        XCTAssertEqual(suggestion.odds, 4096)
    }

    func test_staysInsideTheJourneysGame() {
        let suggester = makeSuggester([.Platinum: [base: [makeRow("Route 201")]], .AlphaSapphire: [base: [makeRow("Route 101")]]])

        let suggestion = suggester.suggest(for: base, preferring: [.AlphaSapphire], mode: .bestOdds, for: .Platinum)!

        XCTAssertEqual(suggestion.game, .Platinum)
        XCTAssertNotEqual(suggestion.method, .DexNav)
    }

    func test_suggestsEncounters_whenTheGameHasItButNoLocationIsListed() {
        let availability = GameAvailability(dataByGame: [.Platinum: GameAvailability.GameData(catchable: [legendary], tradeOnly: [], isApproximate: false)])
        let suggester = HuntSuggester(locations: PokemonLocations(locationsByGame: [.Platinum: [:]]), availability: availability, evolutions: Evolutions(evolvesFrom: [-1, 0, -1]),
                                      catchData: PokemonCatchData(), odds: odds)

        let suggestion = suggester.suggest(for: legendary, preferring: [], mode: .fullOdds, for: .Platinum)

        XCTAssertEqual(suggestion?.method, .Encounters)
        XCTAssertNil(suggestion?.area)
    }

    func test_noSuggestion_forASpeciesFromALaterGeneration() {
        XCTAssertNil(makeSuggester([:]).suggest(for: tepig, preferring: [], mode: .fullOdds, for: .Platinum))
    }

    func test_suggestsATradePartner_whenTheJourneysGameLacksIt() {
        let lacksLegendary = GameAvailability.GameData(catchable: [base, evolved], tradeOnly: [], isApproximate: false)
        let pearlHasIt = GameAvailability.GameData(catchable: [legendary], tradeOnly: [], isApproximate: false)
        let availability = GameAvailability(dataByGame: [.Diamond: lacksLegendary, .Platinum: lacksLegendary, .Heartgold: lacksLegendary, .SoulSilver: lacksLegendary, .Pearl: pearlHasIt])
        let suggester = HuntSuggester(locations: PokemonLocations(locationsByGame: [.Pearl: [legendary: [makeRow("Route 222")]]]), availability: availability,
                                      evolutions: Evolutions(evolvesFrom: [-1, 0, -1]), catchData: PokemonCatchData(), odds: odds)

        let suggestion = suggester.suggest(for: legendary, preferring: [.Scarlet], mode: .fullOdds, for: .Platinum)

        XCTAssertEqual(suggestion?.game, .Pearl)
        XCTAssertEqual(suggestion?.area, "Route 222")
    }

    func test_tradeGroupsPutTheJourneysGameFirst() {
        XCTAssertEqual(TradeGroups.findPartners(of: .Platinum), [.Platinum, .Diamond, .Pearl, .Heartgold, .SoulSilver])
        XCTAssertTrue(TradeGroups.findTransferSources(for: .Platinum).contains(.Emerald))
        XCTAssertFalse(TradeGroups.findTransferSources(for: .Platinum).contains(.Black))
    }

    func test_pickerOnlyOffersSpeciesThatExistByTheJourneysGeneration() {
        let everyone = InMemoryPokemonRepository(names: (0...tepig).map { "Pokemon \($0)" })
        let handler = GetAllPokemonHandler(pokemonRepository: everyone)

        let forPlatinum = handler.handle(GetAllPokemonQuery(obtainableFor: .Platinum)).map { $0.number }

        XCTAssertTrue(forPlatinum.contains(base))
        XCTAssertFalse(forPlatinum.contains(tepig))
        XCTAssertTrue(handler.handle(GetAllPokemonQuery()).map { $0.number }.contains(tepig))
    }

    func test_journeyDetailsSayWhatCantBeFoundInTheJourneysGame() {
        let journey = Journey(id: UUID(), name: "Platinum run", createdDate: Date(), priority: 0, entries: [JourneyEntry(number: base), JourneyEntry(number: tepig)],
                              game: .Platinum)
        _ = journeys.save(journey)
        let finder = HuntSuggestionFinder(suggester: makeSuggester([.Platinum: [base: [makeRow("Route 201")]]]), catchRepository: catches, pokemonRepository: pokemon,
                                          getMode: GetHuntSuggestionModeHandler(keyValueStore: store))
        let handler = GetJourneyDetailsHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, evolutions: Evolutions(evolvesFrom: [-1, 0, -1]),
                                               suggestionFinder: finder)

        let details = handler.handle(GetJourneyDetailsQuery(journeyId: JourneyID(rawValue: journey.id)))!

        XCTAssertEqual(details.game, .Platinum)
        XCTAssertEqual(details.entries[0].suggestion?.game, .Platinum)
        XCTAssertNil(details.entries[0].missingFromGame)
        XCTAssertNil(details.entries[1].suggestion)
        XCTAssertEqual(details.entries[1].missingFromGame, .Platinum)
    }

    func test_settingAJourneysGame() {
        let journey = Journey(name: "Run", priority: 0, numbers: [base])
        _ = journeys.save(journey)
        let handler = UpdateJourneyHandler(journeyRepository: journeys)

        handler.handle(UpdateJourneyCommand(journeyId: JourneyID(rawValue: journey.id), change: .setGame(.Platinum)))
        XCTAssertEqual(journeys.getAll().first?.game, .Platinum)
        handler.handle(UpdateJourneyCommand(journeyId: JourneyID(rawValue: journey.id), change: .setGame(nil)))
        XCTAssertNil(journeys.getAll().first?.game)
    }

    func test_fallsBackToOtherGames_whenThePreferredOnesHaveNoWayToHuntIt() {
        let suggester = makeSuggester([.Diamond: [legendary: [makeRow("Spear Pillar", method: "Static encounter", isShinyLocked: true)]]], shinyLockedIn: .Diamond)

        let suggestion = suggester.suggest(for: legendary, preferring: [.Diamond])

        XCTAssertNotNil(suggestion)
        XCTAssertNotEqual(suggestion?.game, .Diamond)
    }

    // MARK: Next hunt

    private func makeFinder() -> HuntSuggestionFinder {
        return HuntSuggestionFinder(suggester: makeSuggester([:]), catchRepository: catches, pokemonRepository: pokemon,
                                    getMode: GetHuntSuggestionModeHandler(keyValueStore: store))
    }

    private func addCatch(of number: Int, game: Games) -> Catch {
        let caught = Catch(number: number, caughtBall: "poke", game: game, huntMethod: .Encounters, encounters: 10, isShinyCharmActive: false, caughtDate: nil, isFailed: false)
        catches.insert(caught)
        return caught
    }

    func test_prefersTheGamesYouCatchInMost() {
        _ = addCatch(of: legendary, game: .Scarlet)
        _ = addCatch(of: legendary, game: .Scarlet)
        _ = addCatch(of: legendary, game: .Sword)

        XCTAssertEqual(makeFinder().findPreferredGames(), [.Scarlet, .Sword])
    }

    func test_nextHuntComesFromTheHighestPriorityJourneyWithSomethingLeft() {
        let caught = addCatch(of: base, game: .Scarlet)
        _ = journeys.save(Journey(id: UUID(), name: "Done", createdDate: Date(), priority: 0, entries: [JourneyEntry(number: base, catchId: caught.id)]))
        _ = journeys.save(Journey(id: UUID(), name: "Later", createdDate: Date(), priority: 2, entries: [JourneyEntry(number: base)]))
        _ = journeys.save(Journey(id: UUID(), name: "Next", createdDate: Date(), priority: 1, entries: [JourneyEntry(number: legendary), JourneyEntry(number: evolved)]))
        store.set(true, forKey: HuntSuggestionKeys.usesBestOdds)
        let handler = GetNextHuntHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, finder: makeFinder())

        let next = handler.handle(GetNextHuntQuery())

        XCTAssertEqual(next?.journeyName, "Next")
        XCTAssertEqual(next?.number, evolved)
        XCTAssertEqual(next?.suggestion.method, .Masuda)
        XCTAssertEqual(next?.suggestion.targetName, "Base")
        XCTAssertEqual(next?.suggestion.isFullOdds, false)
    }

    func test_suggestionsUseFullOddsUntilBestOddsIsChosen() {
        let finder = makeFinder()

        XCTAssertEqual(finder.findSuggestion(for: evolved, preferring: [.Scarlet], allPokemon: pokemon.getAll())?.isFullOdds, true)
        ChooseHuntSuggestionModeHandler(keyValueStore: store).handle(ChooseHuntSuggestionModeCommand(mode: .bestOdds))
        XCTAssertEqual(finder.findSuggestion(for: evolved, preferring: [.Scarlet], allPokemon: pokemon.getAll())?.method, .Masuda)
        XCTAssertEqual(GetHuntSuggestionModeHandler(keyValueStore: store).handle(GetHuntSuggestionModeQuery()), .bestOdds)
    }

    func test_noNextHunt_withoutJourneys() {
        let handler = GetNextHuntHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, finder: makeFinder())

        XCTAssertNil(handler.handle(GetNextHuntQuery()))
    }

    // MARK: Pokédex

    func test_pokedexMarksSpeciesWantedByAnUnfinishedJourney() {
        let caught = addCatch(of: base, game: .Scarlet)
        _ = journeys.save(Journey(id: UUID(), name: "Team", createdDate: Date(), priority: 0,
                                  entries: [JourneyEntry(number: base, catchId: caught.id), JourneyEntry(number: evolved)]))
        let handler = GetPokedexHandler(pokemonRepository: pokemon, catchRepository: catches, journeyRepository: journeys)

        let entries = handler.handle(GetPokedexQuery(region: 0)).entries

        XCTAssertNil(entries[base].journeyName)
        XCTAssertEqual(entries[evolved].journeyName, "Team")
        XCTAssertNil(entries[legendary].journeyName)
    }
}
