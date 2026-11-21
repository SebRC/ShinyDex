import XCTest
@testable import ShinyDex

final class PPPresetTests: XCTestCase {
    private var loader: BundleResourceLoader!
    private var moves: InMemoryMoveRepository!

    override func setUp() {
        loader = BundleResourceLoader(bundle: Bundle(for: AppDelegate.self))
        moves = InMemoryMoveRepository()
        moves.insert(ActiveMoves(moves: [ActiveMove(name: "Tackle", maxPP: 35, remainingPP: 3, type: "Normal")], pressureActive: false))
    }

    private func makePreset(id: String = "test", moves: [String]) -> PPPreset {
        return PPPreset(id: id, pokemonName: "Dialga", game: "Platinum", onlyIn: nil, level: 70, isRoaming: false, moveIdentifiers: moves)
    }

    private func getSummaries(of presets: PPPresets) -> [PPPresetSummary] {
        return GetPPPresetsHandler(presets: presets, getMoveOptions: GetMoveOptionsHandler(resourceLoader: loader)).handle(GetPPPresetsQuery())
    }

    @discardableResult
    private func apply(_ presetId: String, from presets: PPPresets) -> Bool {
        return ApplyPPPresetHandler(presets: presets, getMoveOptions: GetMoveOptionsHandler(resourceLoader: loader), moveRepository: moves)
            .handle(ApplyPPPresetCommand(presetId: presetId))
    }

    private func getTrackedMoves() -> ActiveMoveSet {
        return GetActiveMovesHandler(moveRepository: moves).handle(GetActiveMovesQuery())
    }

    // MARK: Bundled presets

    func test_everyBundledPreset_resolvesAllItsMoves_andKnowsAtMostFour() {
        let bundled = PPPresetsLoader.load(from: loader)
        let summariesById = Dictionary(uniqueKeysWithValues: getSummaries(of: bundled).map { ($0.id, $0) })

        XCTAssertGreaterThan(bundled.presets.count, 200)
        XCTAssertEqual(Set(bundled.presets.map { $0.id }).count, bundled.presets.count, "Preset ids are unique")
        for preset in bundled.presets {
            XCTAssertEqual(summariesById[preset.id]?.moveNames.count, preset.moveIdentifiers.count, "\(preset.id) has a move the app doesn't know")
            XCTAssertTrue((1...4).contains(preset.moveIdentifiers.count), preset.id)
        }
    }

    func test_bundledPresets_namePokemonTheAppKnows() {
        let names = Set(loader.loadLines(ofTextResource: "allGens"))

        for preset in PPPresetsLoader.load(from: loader).presets {
            XCTAssertTrue(names.contains(preset.pokemonName), preset.pokemonName)
        }
    }

    func test_platinumDialga_knowsItsLevel70Moves() {
        let dialga = getSummaries(of: PPPresetsLoader.load(from: loader)).first { $0.game == "Platinum" && $0.pokemonName == "Dialga" }

        XCTAssertEqual(dialga?.level, 70)
        XCTAssertEqual(dialga?.moveNames, ["Roar of time", "Heal block", "Earth power", "Slash"])
    }

    func test_versionExclusives_andRoamers_areMarked() {
        let summaries = getSummaries(of: PPPresetsLoader.load(from: loader))

        let goldLugia = summaries.first { $0.game == "Gold / Silver" && $0.pokemonName == "Lugia" && $0.level == 70 }
        XCTAssertEqual(goldLugia?.onlyIn, "Gold")
        let raikou = summaries.first { $0.game == "Gold / Silver" && $0.pokemonName == "Raikou" }
        XCTAssertEqual(raikou?.isRoaming, true)
        XCTAssertNil(raikou?.onlyIn)
    }

    // MARK: Summaries

    func test_unknownMoves_areSkipped_andAPresetWithNoKnownMovesIsLeftOut() {
        let presets = PPPresets(presets: [makePreset(id: "partly", moves: ["spore", "not-a-move"]), makePreset(id: "unknown", moves: ["not-a-move"])])

        XCTAssertEqual(getSummaries(of: presets).map { $0.id }, ["partly"])
        XCTAssertEqual(getSummaries(of: presets).first?.moveNames, ["Spore"])
    }

    // MARK: Applying

    func test_applyingAPreset_tracksItsMovesWithFullPP() {
        let presets = PPPresets(presets: [makePreset(moves: ["roar-of-time", "heal-block", "earth-power", "slash"])])

        XCTAssertTrue(apply("test", from: presets))

        XCTAssertEqual(getTrackedMoves().slots, [
            MoveSlot(name: "Roar of time", maxPP: 5, remainingPP: 5, type: "Dragon"),
            MoveSlot(name: "Heal block", maxPP: 15, remainingPP: 15, type: "Psychic"),
            MoveSlot(name: "Earth power", maxPP: 10, remainingPP: 10, type: "Ground"),
            MoveSlot(name: "Slash", maxPP: 20, remainingPP: 20, type: "Normal")
        ])
    }

    func test_applyingAPreset_leavesPressureAsItWas() {
        let presets = PPPresets(presets: [makePreset(moves: ["slash"])])

        apply("test", from: presets)
        XCTAssertFalse(getTrackedMoves().pressureActive)

        moves.save(ActiveMoves(moves: [], pressureActive: true))
        apply("test", from: presets)
        XCTAssertTrue(getTrackedMoves().pressureActive)
    }

    func test_applyingAnUnknownPreset_orOneWithNoKnownMoves_leavesTheMovesAlone() {
        let presets = PPPresets(presets: [makePreset(id: "unknown", moves: ["not-a-move"])])

        XCTAssertFalse(apply("missing", from: presets))
        XCTAssertFalse(apply("unknown", from: presets))

        XCTAssertEqual(getTrackedMoves().slots, [MoveSlot(name: "Tackle", maxPP: 35, remainingPP: 3, type: "Normal")])
    }
}
