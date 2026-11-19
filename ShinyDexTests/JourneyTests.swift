import XCTest
@testable import ShinyDex

class JourneyTests: XCTestCase {
	fileprivate let bulbasaur = 0, charmander = 3, squirtle = 6

	fileprivate func makeCatch(number: Int, date: Date?, isFailed: Bool = false) -> Catch {
		return Catch(number: number, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 100, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed)
	}

	fileprivate func day(_ day: Int) -> Date {
		return DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 1, day: day).date!
	}

	fileprivate func byId(_ catches: [Catch]) -> [UUID: Catch] {
		return Dictionary(uniqueKeysWithValues: catches.map { ($0.id, $0) })
	}

	func test_newEntries_startUncaught() {
		let journey = Journey(name: "Badge quest", priority: 0, numbers: [bulbasaur, charmander])
		let existing = makeCatch(number: bulbasaur, date: day(1))

		XCTAssertEqual(journey.caughtCount(in: byId([existing])), 0, "Owning a catch of the species doesn't tick off the entry")
		XCTAssertTrue(journey.entries.allSatisfy { $0.catchId == nil })
	}

	func test_linkedCatch_countsOnlyWhileTheCatchExistsAndWasCaught() {
		let journey = Journey(name: "Dream team", priority: 0, numbers: [bulbasaur, charmander])
		let caught = makeCatch(number: bulbasaur, date: day(1))
		let gotAway = makeCatch(number: charmander, date: day(2), isFailed: true)
		journey.entries[0].catchId = caught.id
		journey.entries[1].catchId = gotAway.id

		XCTAssertEqual(journey.caughtCount(in: byId([caught, gotAway])), 1)
		XCTAssertEqual(journey.caughtCount(in: byId([gotAway])), 0, "A deleted catch leaves its entry uncaught")
	}

	func test_timeline_isOrderedByCatchDate_withUndatedLast() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander, squirtle])
		let late = makeCatch(number: bulbasaur, date: day(20))
		let undated = makeCatch(number: charmander, date: nil)
		let early = makeCatch(number: squirtle, date: day(3))
		for (index, caught) in [late, undated, early].enumerated() {
			journey.entries[index].catchId = caught.id
		}

		let order = journey.timeline(in: byId([late, undated, early])).map { $0.caught.id }

		XCTAssertEqual(order, [early.id, late.id, undated.id])
	}

	func test_timeline_leavesOutUnlinkedEntries() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander])
		let caught = makeCatch(number: charmander, date: day(1))
		journey.entries[1].catchId = caught.id

		XCTAssertEqual(journey.timeline(in: byId([caught])).map { $0.entry.number }, [charmander])
	}

	func test_entries_roundTripThroughTheirStoredForm() throws {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, bulbasaur])
		journey.entries[1].catchId = UUID()

		let decoded = try XCTUnwrap(StoredJourneyEntry.decode(StoredJourneyEntry.encode(journey.entries)))

		XCTAssertEqual(decoded, journey.entries)
		XCTAssertNotEqual(decoded[0].id, decoded[1].id, "The same species can be in a journey twice")
	}
}
