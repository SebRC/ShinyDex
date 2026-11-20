import XCTest
@testable import ShinyDex

class ProbabilityServiceTests: XCTestCase {
    var probabilityService: ProbabilityService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        probabilityService = ProbabilityService()
    }

    override func tearDownWithError() throws {
        probabilityService = nil
        try super.tearDownWithError()
    }

    func test_normalOdds_returnsWithReasonableAccuracy() {
        let entries = [756: 8.82, 14017: 81.93, 1849: 20.21, 2318: 24.65, 1000000: 100.0]

        for entry in entries {
            let actualProbability = probabilityService.getProbability(encounters: entry.key, shinyOdds: 8192)
            XCTAssertEqual(actualProbability, entry.value, accuracy: 0.01)
        }
    }
}
