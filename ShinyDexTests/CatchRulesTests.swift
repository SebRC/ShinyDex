import XCTest
@testable import ShinyDex

class CatchRulesTests: XCTestCase {
	fileprivate func makeCatch(number: Int = 0, ball: String, date: Date?) -> Catch {
		return Catch(number: number, caughtBall: ball, game: .Red, huntMethod: .Encounters, encounters: 0, isShinyCharmActive: false, caughtDate: date)
	}

	func test_sorted_undatedCatchesComeFirst_thenByDate() {
		let newer = makeCatch(ball: "ultra", date: Date(timeIntervalSince1970: 200))
		let older = makeCatch(ball: "great", date: Date(timeIntervalSince1970: 100))
		let undated = makeCatch(ball: "poke", date: nil)

		let sorted = CatchRules.sorted([newer, undated, older])

		XCTAssertEqual(sorted.map { $0.caughtBall }, ["poke", "great", "ultra"])
	}

	func test_latestBall_isNoneWithoutCatches() {
		XCTAssertEqual(CatchRules.latestBall(of: []), CatchRules.noBall)
	}

	func test_latestBall_isMostRecentCatch() {
		let catches = [makeCatch(ball: "master", date: Date(timeIntervalSince1970: 300)), makeCatch(ball: "poke", date: nil)]
		XCTAssertEqual(CatchRules.latestBall(of: catches), "master")
	}

	func test_countsByNumber_countsDuplicates() {
		let catches = [makeCatch(number: 1, ball: "poke", date: nil), makeCatch(number: 1, ball: "great", date: nil), makeCatch(number: 4, ball: "ultra", date: nil)]
		XCTAssertEqual(CatchRules.countsByNumber(catches), [1: 2, 4: 1])
	}

	func test_pokemonToBackfill_onlyCaughtSpeciesWithoutCatches() {
		let caught = Pokemon(); caught.number = 0; caught.caughtBall = "poke"
		let notCaught = Pokemon(); notCaught.number = 1; notCaught.caughtBall = "none"
		let alreadyCopied = Pokemon(); alreadyCopied.number = 2; alreadyCopied.caughtBall = "ultra"

		let result = CatchRules.pokemonToBackfill(from: [caught, notCaught, alreadyCopied], existingCounts: [2: 1])

		XCTAssertEqual(result.map { $0.number }, [0])
	}
}
