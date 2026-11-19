import XCTest
@testable import ShinyDex

class CatchTraitsTests: XCTestCase {
	func test_natures_raiseAndLowerTheExpectedStats() {
		XCTAssertEqual(Nature.adamant.raisedStat, .attack)
		XCTAssertEqual(Nature.adamant.loweredStat, .specialAttack)
		XCTAssertEqual(Nature.timid.raisedStat, .speed)
		XCTAssertEqual(Nature.timid.loweredStat, .attack)
		XCTAssertEqual(Nature.modest.raisedStat, .specialAttack)
		XCTAssertEqual(Nature.modest.loweredStat, .attack)
		XCTAssertEqual(Nature.careful.raisedStat, .specialDefense)
		XCTAssertEqual(Nature.careful.loweredStat, .specialAttack)
		XCTAssertEqual(Nature.impish.raisedStat, .defense)
		XCTAssertEqual(Nature.impish.loweredStat, .specialAttack)
		XCTAssertEqual(Nature.adamant.effectSummary, "+Atk −SpA")
	}

	func test_thereAre25Natures_andFiveAreNeutral() {
		XCTAssertEqual(Nature.allCases.count, 25)
		XCTAssertEqual(Set(Nature.allCases.filter { $0.isNeutral }), [.hardy, .docile, .serious, .bashful, .quirky])
		XCTAssertNil(Nature.serious.raisedStat)
		XCTAssertEqual(Nature.serious.effectSummary, "Neutral")
	}

	func test_grid_rowsRaiseAndColumnsLowerTheGridStats() {
		let grid = Nature.grid

		XCTAssertEqual(grid.count, 5)
		for (row, natures) in grid.enumerated() {
			XCTAssertEqual(natures.count, 5)
			for (column, nature) in natures.enumerated() where row != column {
				XCTAssertEqual(nature.raisedStat, Nature.gridStats[row])
				XCTAssertEqual(nature.loweredStat, Nature.gridStats[column])
			}
			XCTAssertTrue(natures[row].isNeutral)
		}
	}

	func test_noNatureAffectsHP() {
		XCTAssertFalse(Nature.allCases.contains { $0.raisedStat == .hp || $0.loweredStat == .hp })
	}

	func test_nickname_isTrimmed_limitedTo12Characters_andBlankMeansNone() {
		let caught = Catch(number: 25, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: nil)

		caught.nickname = "  Pika  "
		XCTAssertEqual(caught.nickname, "Pika")

		caught.nickname = "Thunderbolter99"
		XCTAssertEqual(caught.nickname, "Thunderbolte")

		caught.nickname = "   "
		XCTAssertNil(caught.nickname)
	}
}
