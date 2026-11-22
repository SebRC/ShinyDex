import XCTest
@testable import ShinyDex

final class CatchAbilitiesTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let bulbasaur = 0, ivysaur = 1, venusaur = 2

    private let abilities = PokemonAbilities(
        namesById: ["overgrow": "Overgrow", "chlorophyll": "Chlorophyll", "thick-fat": "Thick Fat", "snow-cloak": "Snow Cloak"],
        rangesByKey: [
            PokemonAbilities.Key(number: 0, formId: nil): [
                PokemonAbilities.GenerationRange(fromGeneration: 3, abilities: AbilitySet(regular: ["overgrow"], hidden: nil)),
                PokemonAbilities.GenerationRange(fromGeneration: 5, abilities: AbilitySet(regular: ["overgrow"], hidden: "chlorophyll"))
            ],
            PokemonAbilities.Key(number: 1, formId: nil): [
                PokemonAbilities.GenerationRange(fromGeneration: 3, abilities: AbilitySet(regular: ["thick-fat"], hidden: nil))
            ],
            PokemonAbilities.Key(number: 2, formId: nil): [
                PokemonAbilities.GenerationRange(fromGeneration: 3, abilities: AbilitySet(regular: ["overgrow"], hidden: nil)),
                PokemonAbilities.GenerationRange(fromGeneration: 5, abilities: AbilitySet(regular: ["overgrow"], hidden: "chlorophyll"))
            ],
            PokemonAbilities.Key(number: 2, formId: "frost"): [
                PokemonAbilities.GenerationRange(fromGeneration: 3, abilities: AbilitySet(regular: ["thick-fat"], hidden: "snow-cloak"))
            ]
        ])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur"])
        catches = InMemoryCatchRepository()
    }

    private func logCatch(of number: Int, in game: Games) throws -> CatchID {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository())
            .handle(LogCatchCommand(number: number, outcome: .caught(ball: "poke"), date: Date(timeIntervalSince1970: 0)))
        let id = CatchID(rawValue: catches.getAll(number: number).last!.id)
        try update(id, .game(game))
        return id
    }

    private func update(_ id: CatchID, _ change: UpdateCatchCommand.Change) throws {
        try UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon, abilities: abilities).handle(UpdateCatchCommand(catchId: id, change: change))
    }

    private func getDetails(_ id: CatchID) -> CatchDetails? {
        return GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: Evolutions(evolvesFrom: [-1, 0, 1]), abilities: abilities)
            .handle(GetCatchDetailsQuery(catchId: id))
    }

    func test_abilities_followTheCatchesGeneration() {
        XCTAssertEqual(abilities.findAbilities(of: bulbasaur, formId: nil, in: .Platinum), AbilitySet(regular: ["overgrow"], hidden: nil))
        XCTAssertEqual(abilities.findAbilities(of: bulbasaur, formId: nil, in: .Scarlet), AbilitySet(regular: ["overgrow"], hidden: "chlorophyll"))
    }

    func test_gamesWithoutAbilities_haveNone() {
        XCTAssertFalse(PokemonAbilities.hasAbilities(.Crystal))
        XCTAssertFalse(PokemonAbilities.hasAbilities(.LetsGoEevee))
        XCTAssertFalse(PokemonAbilities.hasAbilities(.LegendsArceus))
        XCTAssertTrue(PokemonAbilities.hasAbilities(.Ruby))
        XCTAssertNil(abilities.findAbilities(of: bulbasaur, formId: nil, in: .Crystal))
    }

    func test_forms_useTheirOwnAbilities_orFallBackToTheSpecies() {
        XCTAssertEqual(abilities.findAbilities(of: venusaur, formId: "frost", in: .Sun)?.regular, ["thick-fat"])
        XCTAssertEqual(abilities.findAbilities(of: venusaur, formId: "cosmetic", in: .Sun)?.regular, ["overgrow"])
    }

    func test_catchDetails_offerTheSpeciesAbilities_withTheHiddenOneMarked() throws {
        let id = try logCatch(of: bulbasaur, in: .Sword)
        try update(id, .ability("chlorophyll"))

        let ability = getDetails(id)?.ability
        XCTAssertEqual(ability?.name, "Chlorophyll")
        XCTAssertEqual(ability?.choices, [AbilityChoice(id: "overgrow", name: "Overgrow", isHidden: false),
                                         AbilityChoice(id: "chlorophyll", name: "Chlorophyll", isHidden: true)])
    }

    func test_catchDetails_haveNoAbility_forGamesWithoutThem() throws {
        let id = try logCatch(of: bulbasaur, in: .Gold)

        XCTAssertNil(getDetails(id)?.ability)
    }

    func test_evolving_keepsTheSameAbilitySlot() throws {
        let id = try logCatch(of: bulbasaur, in: .Sword)
        try update(id, .ability("chlorophyll"))

        try EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon, abilities: abilities).handle(EvolveCatchCommand(catchId: id, targetNumber: venusaur))

        XCTAssertEqual(catches.get(id: id.rawValue)?.ability, "chlorophyll")
    }

    func test_changingForm_movesTheAbilityToTheSameSlotOfTheNewForm() throws {
        let id = try logCatch(of: venusaur, in: .Sword)
        try update(id, .ability("chlorophyll"))

        let changed = PokemonAbilities.Key(number: venusaur, formId: "frost")
        XCTAssertEqual(abilities.carryOver("chlorophyll", from: PokemonAbilities.Key(number: venusaur, formId: nil), to: changed, in: .Sword), "snow-cloak")
        XCTAssertEqual(abilities.carryOver("overgrow", from: PokemonAbilities.Key(number: venusaur, formId: nil), to: changed, in: .Sword), "thick-fat")
    }

    func test_aSingleAbility_isAssigned_andCantBeChanged() throws {
        let id = try logCatch(of: bulbasaur, in: .Platinum)
        XCTAssertEqual(catches.get(id: id.rawValue)?.ability, "overgrow")

        try update(id, .ability(nil))

        let ability = getDetails(id)?.ability
        XCTAssertEqual(ability?.name, "Overgrow")
        XCTAssertEqual(ability?.isFixed, true)
        XCTAssertEqual(catches.get(id: id.rawValue)?.ability, "overgrow")
    }

    func test_changingToAGameWithMoreAbilities_keepsTheAssignedOne() throws {
        let id = try logCatch(of: bulbasaur, in: .Platinum)

        try update(id, .game(.Sword))

        XCTAssertEqual(catches.get(id: id.rawValue)?.ability, "overgrow")
        XCTAssertEqual(getDetails(id)?.ability?.isFixed, false)
    }

    func test_evolvingIntoASpeciesWithOneAbility_takesIt() throws {
        let id = try logCatch(of: bulbasaur, in: .Sword)
        try update(id, .ability("chlorophyll"))

        try EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon, abilities: abilities).handle(EvolveCatchCommand(catchId: id, targetNumber: ivysaur))

        XCTAssertEqual(catches.get(id: id.rawValue)?.ability, "thick-fat")
    }

    func test_bundledData_knowsAbilitiesAcrossGenerationsAndForms() {
        let bundled = PokemonAbilitiesLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppContainer.self)))

        XCTAssertEqual(bundled.findAbilities(of: 93, formId: nil, in: .Platinum)?.regular, ["levitate"], "Gengar before Gen 7")
        XCTAssertEqual(bundled.findAbilities(of: 93, formId: nil, in: .Sun)?.regular, ["cursed-body"])
        XCTAssertEqual(bundled.findAbilities(of: 24, formId: nil, in: .Scarlet), AbilitySet(regular: ["static"], hidden: "lightning-rod"))
        XCTAssertNil(bundled.findAbilities(of: 24, formId: nil, in: .Emerald)?.hidden, "No hidden abilities before Gen 5")
        XCTAssertEqual(bundled.findAbilities(of: 36, formId: "alola", in: .Sun), AbilitySet(regular: ["snow-cloak"], hidden: "snow-warning"))
        XCTAssertEqual(bundled.findAbilities(of: 200, formId: "question", in: .Emerald)?.regular, ["levitate"], "Unown forms share the species ability")
        XCTAssertEqual(bundled.findName(of: "lightning-rod"), "Lightning Rod")
    }
}
