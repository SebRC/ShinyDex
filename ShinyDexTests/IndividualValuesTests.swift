import XCTest
@testable import ShinyDex

class IndividualValuesTests: XCTestCase {
	func test_newValues_areUnknown() {
		let ivs = IndividualValues()

		XCTAssertTrue(ivs.isEmpty)
		XCTAssertNil(ivs[.attack])
		XCTAssertEqual(ivs.summary, "Unknown")
	}

	func test_setting_clampsTo0Through31() {
		let ivs = IndividualValues().setting(40, for: .hp).setting(-3, for: .speed)

		XCTAssertEqual(ivs[.hp], 31)
		XCTAssertEqual(ivs[.speed], 0)
	}

	func test_settingNil_makesTheStatUnknownAgain() {
		let ivs = IndividualValues().setting(31, for: .defense).setting(nil, for: .defense)

		XCTAssertTrue(ivs.isEmpty)
	}

	func test_encoding_roundTripsUnknownStats() {
		let ivs = IndividualValues().setting(31, for: .hp).setting(0, for: .attack).setting(25, for: .speed)

		XCTAssertEqual(ivs.encoded, "31,0,,,,25")
		XCTAssertEqual(IndividualValues(encoded: ivs.encoded), ivs)
	}

	func test_decoding_clampsOutOfRangeValues() {
		let ivs = IndividualValues(encoded: "99,-1,,,,31")

		XCTAssertEqual(ivs[.hp], 31)
		XCTAssertEqual(ivs[.attack], 0)
		XCTAssertNil(ivs[.defense])
	}

	func test_decoding_malformedText_givesUnknownValues() {
		XCTAssertTrue(IndividualValues(encoded: "31,31").isEmpty)
		XCTAssertTrue(IndividualValues(encoded: "31,x,31,31,31,31").isEmpty)
		XCTAssertTrue(IndividualValues(encoded: nil).isEmpty)
	}

	func test_perfectCount_andSummary() {
		let ivs = IndividualValues(encoded: "31,0,31,,31,30")

		XCTAssertEqual(ivs.perfectCount, 3)
		XCTAssertEqual(ivs.summary, "31 / 0 / 31 / ? / 31 / 30")
	}
}
