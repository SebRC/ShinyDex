import XCTest
@testable import ShinyDex

final class CollectionFilterTests: XCTestCase {
    private func makeSummary(number: Int = 0, game: Games = .Emerald, nature: Nature? = nil, gender: Gender? = nil, ivs: IndividualValues = IndividualValues(), isFailed: Bool = false) -> CatchSummary {
        let caught = Catch(number: number, caughtBall: "poke", game: game, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil, isFailed: isFailed)
        caught.nature = nature
        caught.gender = gender
        caught.ivs = ivs
        let pokemon = [Pokemon(newlyAddedNamed: "Bulbasaur", number: 0), Pokemon(newlyAddedNamed: "Magnemite", number: 1)]
        return CatchSummaryMapper(allPokemon: pokemon, forms: PokemonForms(), genders: PokemonGenders(fixedGendersByNumber: [1: .genderless])).makeSummary(of: caught)!
    }

    func test_genderFilters_useFixedGenders_andFindCatchesWithoutOne() {
        XCTAssertTrue(CollectionFilter.gender(.female).matches(makeSummary(gender: .female)))
        XCTAssertFalse(CollectionFilter.gender(.female).matches(makeSummary(gender: .male)))
        XCTAssertTrue(CollectionFilter.gender(.genderless).matches(makeSummary(number: 1)), "Magnemite is always genderless")
        XCTAssertTrue(CollectionFilter.missingGender.matches(makeSummary()))
        XCTAssertFalse(CollectionFilter.missingGender.matches(makeSummary(number: 1)))
        XCTAssertFalse(CollectionFilter.missingGender.matches(makeSummary(isFailed: true)))
    }

    func test_missingNature_matchesCaughtShiniesWithoutANature() {
        let filter = CollectionFilter.missingNature

        XCTAssertTrue(filter.matches(makeSummary(nature: nil)))
        XCTAssertFalse(filter.matches(makeSummary(nature: .timid)))
        XCTAssertFalse(filter.matches(makeSummary(nature: nil, isFailed: true)), "Ones that got away can't have a nature logged")
        XCTAssertFalse(filter.showsFailed)
        XCTAssertEqual(filter.title, "No nature logged")
    }

    func test_missingIVs_matchesCaughtShiniesFromGenThreeOn_withNoIVsLogged() {
        let filter = CollectionFilter.missingIVs

        XCTAssertTrue(filter.matches(makeSummary()))
        XCTAssertFalse(filter.matches(makeSummary(ivs: IndividualValues().setting(31, for: .hp))), "One logged IV is enough")
        XCTAssertFalse(filter.matches(makeSummary(game: .Crystal)), "Gen 1–2 games use DVs")
        XCTAssertFalse(filter.matches(makeSummary(isFailed: true)))
        XCTAssertEqual(filter.title, "No IVs logged")
    }
}
