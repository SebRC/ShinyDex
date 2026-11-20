import XCTest
@testable import ShinyDex

class EvolutionsTests: XCTestCase {
	fileprivate let bulbasaur = 0, ivysaur = 1, venusaur = 2
	fileprivate let eevee = 132, vaporeon = 133, sylveon = 699
	fileprivate let pichu = 171, pikachu = 24, raichu = 25
	fileprivate let tauros = 127
	fileprivate let primeape = 56, annihilape = 978

	fileprivate var evolutions: Evolutions {
		return EvolutionsLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppDelegate.self)))
	}

	func test_bundledData_coversEveryPokemon() {
		XCTAssertEqual(evolutions.evolvesFrom.count, 1010)
	}

	func test_line_isOrderedByStage() {
		XCTAssertEqual(evolutions.getLine(of: venusaur), [bulbasaur, ivysaur, venusaur])
		XCTAssertEqual(evolutions.getLine(of: pikachu), [pichu, pikachu, raichu])
	}

	func test_line_includesEveryBranch() {
		let line = evolutions.getLine(of: vaporeon)
		XCTAssertEqual(line.first, eevee)
		XCTAssertEqual(line.count, 9, "Eevee and its eight evolutions")
		XCTAssertTrue(line.contains(sylveon))
	}

	func test_line_includesLaterGenerationEvolutions() {
		XCTAssertTrue(evolutions.getLine(of: primeape).contains(annihilape))
	}

	func test_targets_areTheRestOfTheLine() {
		XCTAssertEqual(evolutions.getEvolutionTargets(of: ivysaur), [bulbasaur, venusaur])
		XCTAssertEqual(evolutions.getEvolutionTargets(of: tauros), [])
	}

	func test_stage_countsStepsFromTheFirstSpecies() {
		XCTAssertEqual(evolutions.getStage(of: bulbasaur), 0)
		XCTAssertEqual(evolutions.getStage(of: venusaur), 2)
		XCTAssertEqual(evolutions.getRoot(of: raichu), pichu)
	}

	func test_customData_handlesMissingAndOutOfRangeNumbers() {
		let small = Evolutions(evolvesFrom: [-1, 0])

		XCTAssertEqual(small.getLine(of: 1), [0, 1])
		XCTAssertNil(small.getParent(of: 5))
		XCTAssertEqual(small.getEvolutionTargets(of: 5), [])
	}
}
