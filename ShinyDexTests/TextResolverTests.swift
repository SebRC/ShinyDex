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
        let entries = [0: "Kanto", 1: "Johto", 2: "Hoenn", 3: "Sinnoh", 4: "Unova", 5: "Kalos", 6: "Alola", 7: "Galar", 8: "Hisui", 9: "Paldea", 10: "Hunts", 11: "Collection", 12: "PP Counter", 13: "Stats", 14: "Journeys", 15: "Shiny Bingo", 16: "Odds Simulator", 17: "Battlers", 18: "Achievements", 19: "Catch Rate", 20: notFoundText, -1: notFoundText]

        for entry in entries {
            let actual = textResolver.getGenTitle(gen: entry.key)
            XCTAssertEqual(actual, entry.value)
        }
    }
}
