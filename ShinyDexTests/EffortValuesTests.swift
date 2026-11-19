import XCTest
@testable import ShinyDex

class EffortValuesTests: XCTestCase {
	func test_adding_stopsAt252PerStat() {
		let evs = EffortValues().adding(250, to: .attack).adding(10, to: .attack)

		XCTAssertEqual(evs[.attack], 252)
	}

	func test_adding_stopsAt510Total() {
		let evs = EffortValues().adding(252, to: .attack).adding(252, to: .speed).adding(10, to: .hp)

		XCTAssertEqual(evs[.hp], 6)
		XCTAssertEqual(evs.total, 510)
		XCTAssertEqual(evs.remaining, 0)
	}

	func test_removing_stopsAtZero() {
		let evs = EffortValues().adding(3, to: .defense).adding(-10, to: .defense)

		XCTAssertEqual(evs[.defense], 0)
	}

	func test_setting_usesTheSameLimits() {
		let evs = EffortValues().adding(252, to: .attack).adding(252, to: .speed)

		XCTAssertEqual(evs.setting(100, for: .hp)[.hp], 6)
		XCTAssertEqual(evs.setting(4, for: .attack)[.attack], 4)
	}

	func test_encoding_roundTrips() {
		let evs = EffortValues().adding(4, to: .hp).adding(252, to: .specialAttack).adding(252, to: .speed)

		XCTAssertEqual(evs.encoded, "4,0,0,252,0,252")
		XCTAssertEqual(EffortValues(encoded: evs.encoded), evs)
	}

	func test_decoding_treatsMalformedAsUntrained_andClampsOutOfRange() {
		XCTAssertTrue(EffortValues(encoded: nil).isEmpty)
		XCTAssertTrue(EffortValues(encoded: "1,2,3").isEmpty)
		XCTAssertTrue(EffortValues(encoded: "a,0,0,0,0,0").isEmpty)

		let clamped = EffortValues(encoded: "300,252,252,0,0,0")
		XCTAssertEqual(clamped[.hp], 252)
		XCTAssertEqual(clamped.total, 510)
	}

	func test_summary_listsTrainedStatsBiggestFirst() {
		let evs = EffortValues().adding(4, to: .hp).adding(252, to: .attack).adding(252, to: .speed)

		XCTAssertEqual(evs.summary, "252 Atk / 252 Spe / 4 HP")
		XCTAssertEqual(EffortValues().summary, "Not trained")
	}
}
