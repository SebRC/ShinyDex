import XCTest
@testable import ShinyDex

final class CatchGendersTests: XCTestCase {
    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private let ralts = 0, kirlia = 1, gallade = 2, magnemite = 3
    private let genders = PokemonGenders(fixedGendersByNumber: [2: .male, 3: .genderless])

    override func setUp() {
        pokemon = InMemoryPokemonRepository(names: ["Ralts", "Kirlia", "Gallade", "Magnemite"])
        catches = InMemoryCatchRepository()
    }

    private func logCatch(of number: Int) -> CatchID {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository(), genders: genders)
            .handle(LogCatchCommand(number: number, outcome: .caught(ball: "poke"), date: Date(timeIntervalSince1970: 0)))
        return CatchID(rawValue: catches.getAll(number: number).last!.id)
    }

    private func update(_ id: CatchID, _ change: UpdateCatchCommand.Change) throws {
        try UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon, genders: genders).handle(UpdateCatchCommand(catchId: id, change: change))
    }

    private func getGender(_ id: CatchID) -> CatchGender? {
        return GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: Evolutions(evolvesFrom: [-1, 0, 1, -1]), genders: genders)
            .handle(GetCatchDetailsQuery(catchId: id))?.gender
    }

    func test_fixedGenderSpecies_areLoggedWithTheirGender_andCantBeChanged() throws {
        let id = logCatch(of: magnemite)
        XCTAssertEqual(catches.get(id: id.rawValue)?.gender, .genderless)

        try update(id, .gender(.female))

        XCTAssertEqual(getGender(id), CatchGender(value: .genderless, choices: [.genderless]))
        XCTAssertEqual(getGender(id)?.isFixed, true)
    }

    func test_speciesWithBothGenders_offerMaleAndFemale_butNotGenderless() throws {
        let id = logCatch(of: ralts)
        XCTAssertNil(catches.get(id: id.rawValue)?.gender)

        try update(id, .gender(.genderless))
        XCTAssertNil(getGender(id)?.value)

        try update(id, .gender(.female))
        XCTAssertEqual(getGender(id), CatchGender(value: .female, choices: [.male, .female]))
    }

    func test_evolvingIntoAFixedGenderSpecies_takesItsGender() throws {
        let id = logCatch(of: kirlia)
        try update(id, .gender(.female))

        try EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon, genders: genders).handle(EvolveCatchCommand(catchId: id, targetNumber: gallade))

        XCTAssertEqual(catches.get(id: id.rawValue)?.gender, .male)
    }

    func test_existingCatches_showTheSpeciesGender() {
        let legacy = Catch(number: gallade, caughtBall: "poke", game: .Platinum, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil)
        catches.insert(legacy)
        XCTAssertNil(catches.get(id: legacy.id)?.gender)

        XCTAssertEqual(getGender(CatchID(rawValue: legacy.id))?.value, .male)
    }

    func test_bundledData_knowsFixedGenders() {
        let bundled = PokemonGendersLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppContainer.self)))

        XCTAssertEqual(bundled.findFixedGender(of: 80), .genderless, "Magnemite")
        XCTAssertEqual(bundled.findFixedGender(of: 474), .male, "Gallade")
        XCTAssertEqual(bundled.findFixedGender(of: 477), .female, "Froslass")
        XCTAssertNil(bundled.findFixedGender(of: 24), "Pikachu")
    }
}
