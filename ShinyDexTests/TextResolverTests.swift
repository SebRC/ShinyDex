import XCTest
@testable import ShinyDex

class TextResolverTests: XCTestCase {

    var textResolver: TextResolver!

    override func setUpWithError() throws {
        try super.setUpWithError()
        textResolver = TextResolver()
    }

    override func tearDownWithError() throws {
        textResolver = nil
        try super.tearDownWithError()
    }

    func test_differentGenerations_returnsCorrectTitles() {
        let notFoundText = "Not found"
        let entries = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hisui", 9: "Paldea", 10: "Hunts", 11: "Collection", 12: "PP Counter", 13: "Stats", 14: "Journeys", 15: notFoundText, -1: notFoundText]

        for entry in entries {
            let actual = textResolver.getGenTitle(gen: entry.key)
            XCTAssertEqual(actual, entry.value)
        }
    }

    func test_withLgpeMaxChainNotReached_onlyShowsMethodVerb() {
        let pokemon = PokemonFixture()
        pokemon.generation = 7
        pokemon.game = .LetsGoEevee
        pokemon.encounters = 20
        let expectedResult = "Catch Combo: \(pokemon.encounters)"

        let actual = textResolver.getEncountersLabelText(pokemon: pokemon.makeDetails())

        XCTAssertEqual(actual, expectedResult)
    }

    func test_withLgpeMaxChainReached_textIncludesSeen() {
        let pokemon = PokemonFixture()
        pokemon.generation = 7
        pokemon.game = .LetsGoEevee
        pokemon.encounters = 35
        let methodDecrement = 5
        pokemon.huntMethod = .Lure
        let expectedResult = "Catch Combo: \(methodDecrement)\nEncounters: \(pokemon.encounters - methodDecrement)"

        let actual = textResolver.getEncountersLabelText(pokemon: pokemon.makeDetails(chainThreshold: methodDecrement))

        XCTAssertEqual(actual, expectedResult)
    }

    func test_Gen2BreedingOrMasuda_textIncludesEggs() {
        let encounters = 35
        let gen2BreddingPokemon = PokemonFixture()
        gen2BreddingPokemon.generation = 4
        gen2BreddingPokemon.encounters = encounters
        gen2BreddingPokemon.huntMethod = .Gen2Breeding

        let masudaPokemon = PokemonFixture()
        masudaPokemon.generation = 4
        masudaPokemon.encounters = encounters
        masudaPokemon.huntMethod = .Masuda
        let expectedResult = "Eggs: \(encounters)"

        let gen2BreedingActual = textResolver.getEncountersLabelText(pokemon: gen2BreddingPokemon.makeDetails())
        let masudaActual = textResolver.getEncountersLabelText(pokemon: masudaPokemon.makeDetails())

        XCTAssertEqual(gen2BreedingActual, expectedResult)
        XCTAssertEqual(masudaActual, expectedResult)
    }

    func test_ChainingMaxChainNotReached_onlyShowsMethodVerb() {
        let encounters = 15
        let sosChainPokemon = PokemonFixture()
        sosChainPokemon.generation = 7
        sosChainPokemon.encounters = encounters
        sosChainPokemon.huntMethod = .SosChaining

        let chainFishPokemon = PokemonFixture()
        chainFishPokemon.generation = 6
        chainFishPokemon.encounters = encounters
        chainFishPokemon.huntMethod = .ChainFishing
        let expectedResult = "Chain: \(encounters)"

        let sosChainActual = textResolver.getEncountersLabelText(pokemon: sosChainPokemon.makeDetails())
        let chainFishActual = textResolver.getEncountersLabelText(pokemon: chainFishPokemon.makeDetails())

        XCTAssertEqual(sosChainActual, expectedResult)
        XCTAssertEqual(chainFishActual, expectedResult)
    }

    func test_ChainingMaxChainReached_textIncludesSeen() {
        let encounters = 50
        let methodDecrement = 10
        let sosChainPokemon = PokemonFixture()
        sosChainPokemon.generation = 7
        sosChainPokemon.encounters = encounters
        sosChainPokemon.huntMethod = .SosChaining

        let chainFishPokemon = PokemonFixture()
        chainFishPokemon.generation = 6
        chainFishPokemon.encounters = encounters
        chainFishPokemon.huntMethod = .ChainFishing
        let expectedResult = "Chain: \(methodDecrement)\nEncounters: \(encounters - methodDecrement)"

        let sosChainActual = textResolver.getEncountersLabelText(pokemon: sosChainPokemon.makeDetails(chainThreshold: methodDecrement))
        let chainFishActual = textResolver.getEncountersLabelText(pokemon: chainFishPokemon.makeDetails(chainThreshold: methodDecrement))

        XCTAssertEqual(sosChainActual, expectedResult)
        XCTAssertEqual(chainFishActual, expectedResult)
    }

    func test_PokeradarMaxChainReached_textIncludesPatches() {
        let encounters = 50
        let methodDecrement = 10

        let pokeradarPokemon = PokemonFixture()
        pokeradarPokemon.generation = 6
        pokeradarPokemon.encounters = encounters
        pokeradarPokemon.huntMethod = .Pokeradar
        let expectedResult = "Chain: \(methodDecrement)\nPatches: \(encounters - methodDecrement)"

        let pokeradarActual = textResolver.getEncountersLabelText(pokemon: pokeradarPokemon.makeDetails(chainThreshold: methodDecrement))

        XCTAssertEqual(pokeradarActual, expectedResult)
    }

    func test_dexNavMaxChainNotReached_onlyShowsMethodVerb() {
        let dexNavPokemon = PokemonFixture()
        dexNavPokemon.generation = 6
        dexNavPokemon.encounters = 50
        dexNavPokemon.huntMethod = .DexNav
        let expectedResult = "Search level: \(dexNavPokemon.encounters)"

        let dexNavActual = textResolver.getEncountersLabelText(pokemon: dexNavPokemon.makeDetails())

        XCTAssertEqual(dexNavActual, expectedResult)
    }

    func test_dexNavMaxChainReached_textIncludesPatches() {
        let methodDecrement = 10
        let dexNavPokemon = PokemonFixture()
        dexNavPokemon.generation = 6
        dexNavPokemon.encounters = 1000
        dexNavPokemon.huntMethod = .DexNav
        let expectedResult = "Search level: \(methodDecrement)\nEncounters: \(dexNavPokemon.encounters - methodDecrement)"

        let dexNavActual = textResolver.getEncountersLabelText(pokemon: dexNavPokemon.makeDetails(chainThreshold: methodDecrement))

        XCTAssertEqual(dexNavActual, expectedResult)
    }

    func test_EncountersMethod_defaultText() {
        let methodDecrement = 10
        let pokemon = PokemonFixture()
        pokemon.generation = 6
        pokemon.encounters = 1000
        pokemon.huntMethod = .Encounters
        let expectedResult = "Encounters: \(pokemon.encounters)"

        let actual = textResolver.getEncountersLabelText(pokemon: pokemon.makeDetails(chainThreshold: methodDecrement))

        XCTAssertEqual(actual, expectedResult)
    }
}
