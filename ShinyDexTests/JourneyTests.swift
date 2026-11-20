import XCTest
@testable import ShinyDex

class JourneyTests: XCTestCase {
	fileprivate let bulbasaur = 0, charmander = 3, squirtle = 6

	fileprivate func makeCatch(number: Int, date: Date?, isFailed: Bool = false) -> Catch {
		return Catch(number: number, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 100, isShinyCharmActive: false, caughtDate: date, isFailed: isFailed)
	}

	fileprivate func makeDay(_ day: Int) -> Date {
		return DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 1, day: day).date!
	}

	fileprivate func indexById(_ catches: [Catch]) -> [UUID: Catch] {
		return Dictionary(uniqueKeysWithValues: catches.map { ($0.id, $0) })
	}

	func test_newEntries_startUncaught() {
		let journey = Journey(name: "Badge quest", priority: 0, numbers: [bulbasaur, charmander])
		let existing = makeCatch(number: bulbasaur, date: makeDay(1))

		XCTAssertEqual(journey.countCaught(in: indexById([existing])), 0, "Owning a catch of the species doesn't tick off the entry")
		XCTAssertTrue(journey.entries.allSatisfy { $0.catchId == nil })
	}

	func test_linkedCatch_countsOnlyWhileTheCatchExistsAndWasCaught() {
		let journey = Journey(name: "Dream team", priority: 0, numbers: [bulbasaur, charmander])
		let caught = makeCatch(number: bulbasaur, date: makeDay(1))
		let gotAway = makeCatch(number: charmander, date: makeDay(2), isFailed: true)
		journey.entries[0].catchId = caught.id
		journey.entries[1].catchId = gotAway.id

		XCTAssertEqual(journey.countCaught(in: indexById([caught, gotAway])), 1)
		XCTAssertEqual(journey.countCaught(in: indexById([gotAway])), 0, "A deleted catch leaves its entry uncaught")
	}

	func test_timeline_isOrderedByCatchDate_withUndatedLast() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander, squirtle])
		let late = makeCatch(number: bulbasaur, date: makeDay(20))
		let undated = makeCatch(number: charmander, date: nil)
		let early = makeCatch(number: squirtle, date: makeDay(3))
		for (index, caught) in [late, undated, early].enumerated() {
			journey.entries[index].catchId = caught.id
		}

		let order = journey.makeTimeline(in: indexById([late, undated, early])).map { $0.caught.id }

		XCTAssertEqual(order, [early.id, late.id, undated.id])
	}

	func test_timeline_leavesOutUnlinkedEntries() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander])
		let caught = makeCatch(number: charmander, date: makeDay(1))
		journey.entries[1].catchId = caught.id

		XCTAssertEqual(journey.makeTimeline(in: indexById([caught])).map { $0.entry.number }, [charmander])
	}

	func test_entries_roundTripThroughTheirStoredForm() throws {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, bulbasaur])
		journey.entries[1].catchId = UUID()

		let decoded = try XCTUnwrap(StoredJourneyEntry.decode(StoredJourneyEntry.encode(journey.entries)))

		XCTAssertEqual(decoded, journey.entries)
		XCTAssertNotEqual(decoded[0].id, decoded[1].id, "The same species can be in a journey twice")
	}

	func test_phases_includeCatchesThatGotAway_andLeaveTheEntryUncaught() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur])
		let caughtPhase = makeCatch(number: charmander, date: makeDay(1))
		let fledPhase = makeCatch(number: squirtle, date: makeDay(2), isFailed: true)
		journey.addPhase(caughtPhase.id, toEntry: journey.entries[0].id)
		journey.addPhase(fledPhase.id, toEntry: journey.entries[0].id)
		let catches = indexById([caughtPhase, fledPhase])

		XCTAssertEqual(journey.getPhases(for: journey.entries[0], in: catches).map { $0.id }, [caughtPhase.id, fledPhase.id])
		XCTAssertEqual(journey.countPhases(in: catches), 2)
		XCTAssertEqual(journey.countCaught(in: catches), 0)
		XCTAssertEqual(journey.countPhases(in: indexById([fledPhase])), 1, "A deleted catch drops out of the phases")
	}

	func test_aCatchIsLinkedOncePerJourney_asTargetOrPhase() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander])
		let squirtleCatch = makeCatch(number: squirtle, date: makeDay(1))
		let bulbasaurCatch = makeCatch(number: bulbasaur, date: makeDay(2))
		journey.entries[0].catchId = bulbasaurCatch.id

		XCTAssertTrue(journey.addPhase(squirtleCatch.id, toEntry: journey.entries[0].id))
		XCTAssertFalse(journey.addPhase(squirtleCatch.id, toEntry: journey.entries[1].id))
		XCTAssertFalse(journey.addPhase(bulbasaurCatch.id, toEntry: journey.entries[1].id))
		XCTAssertTrue(journey.isLinked(squirtleCatch))

		journey.removePhase(squirtleCatch.id, fromEntry: journey.entries[0].id)

		XCTAssertFalse(journey.isLinked(squirtleCatch))
	}

	func test_timeline_interleavesPhasesByDate_withPhasesBeforeTheirTargetOnTheSameDay() {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur, charmander])
		let bulbasaurCatch = makeCatch(number: bulbasaur, date: makeDay(5))
		let sameDayPhase = makeCatch(number: squirtle, date: makeDay(5), isFailed: true)
		let earlyPhase = makeCatch(number: squirtle, date: makeDay(1))
		let charmanderCatch = makeCatch(number: charmander, date: makeDay(3))
		journey.entries[0].catchId = bulbasaurCatch.id
		journey.entries[1].catchId = charmanderCatch.id
		journey.addPhase(sameDayPhase.id, toEntry: journey.entries[0].id)
		journey.addPhase(earlyPhase.id, toEntry: journey.entries[1].id)

		let timeline = journey.makeTimeline(in: indexById([bulbasaurCatch, sameDayPhase, earlyPhase, charmanderCatch]))

		XCTAssertEqual(timeline.map { $0.caught.id }, [earlyPhase.id, charmanderCatch.id, sameDayPhase.id, bulbasaurCatch.id])
		XCTAssertEqual(timeline.map { $0.isPhase }, [true, false, true, false])
		XCTAssertEqual(timeline.map { $0.entry.number }, [charmander, charmander, bulbasaur, bulbasaur])
	}

	func test_phases_roundTripThroughTheirStoredForm() throws {
		let journey = Journey(name: "Starters", priority: 0, numbers: [bulbasaur])
		journey.entries[0].phaseCatchIds = [UUID(), UUID()]

		let decoded = try XCTUnwrap(StoredJourneyEntry.decode(StoredJourneyEntry.encode(journey.entries)))

		XCTAssertEqual(decoded, journey.entries)
	}

	func test_entriesStoredBeforePhases_decodeWithoutPhases() throws {
		let entryId = UUID(), catchId = UUID()
		let json = "[{\"id\":\"\(entryId.uuidString)\",\"number\":25,\"catchId\":\"\(catchId.uuidString)\"}]"

		let decoded = try XCTUnwrap(StoredJourneyEntry.decode(json))

		XCTAssertEqual(decoded, [JourneyEntry(id: entryId, number: 25, catchId: catchId)])
		XCTAssertFalse(StoredJourneyEntry.encode(decoded).contains("phaseCatchIds"), "Entries without phases keep their old stored form")
	}
}
