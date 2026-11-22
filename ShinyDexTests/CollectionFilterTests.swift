import XCTest
@testable import ShinyDex

final class CollectionFilterTests: XCTestCase {
    private func makeSummary(nature: Nature?, isFailed: Bool = false) -> CatchSummary {
        let caught = Catch(number: 0, caughtBall: "poke", game: .Emerald, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil, isFailed: isFailed)
        caught.nature = nature
        return CatchSummaryMapper(allPokemon: [Pokemon(newlyAddedNamed: "Bulbasaur", number: 0)], forms: PokemonForms()).makeSummary(of: caught)!
    }

    func test_missingNature_matchesCaughtShiniesWithoutANature() {
        let filter = CollectionFilter.missingNature

        XCTAssertTrue(filter.matches(makeSummary(nature: nil)))
        XCTAssertFalse(filter.matches(makeSummary(nature: .timid)))
        XCTAssertFalse(filter.matches(makeSummary(nature: nil, isFailed: true)), "Ones that got away can't have a nature logged")
        XCTAssertFalse(filter.showsFailed)
        XCTAssertEqual(filter.title, "No nature logged")
    }
}
