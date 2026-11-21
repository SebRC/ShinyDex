import XCTest
@testable import ShinyDex

final class GameAvailabilityTests: XCTestCase {
    private let bulbasaur = 0, alakazam = 64, vulpix = 36, chikorita = 151, snivy = 494, wyrdeer = 898, sprigatito = 905

    private func makeAvailability() -> GameAvailability {
        let resources = StubResourceLoader()
        resources.dataResources["gameAvailability.json"] = Data("""
        {"Red":{"catchable":[1],"shinyLocked":[150],"tradeOnly":[37,65],"approximate":false},
         "Scarlet":{"catchable":[906],"tradeOnly":[1],"approximate":true},
         "Not a game":{"catchable":[1],"tradeOnly":[],"approximate":false}}
        """.utf8)
        return GameAvailabilityLoader.load(from: resources)
    }

    func test_introducedGeneration_followsTheNationalDex() {
        XCTAssertEqual(GameAvailability.findIntroducedGeneration(of: bulbasaur), 1)
        XCTAssertEqual(GameAvailability.findIntroducedGeneration(of: chikorita), 2)
        XCTAssertEqual(GameAvailability.findIntroducedGeneration(of: snivy), 5)
        XCTAssertEqual(GameAvailability.findIntroducedGeneration(of: wyrdeer), 8)
        XCTAssertEqual(GameAvailability.findIntroducedGeneration(of: sprigatito), 9)
        XCTAssertNil(GameAvailability.findIntroducedGeneration(of: 5000))
    }

    func test_availability_comesFromTheGameData() {
        let availability = makeAvailability()

        XCTAssertEqual(availability.findAvailability(of: bulbasaur, in: .Red), .catchable)
        XCTAssertEqual(availability.findAvailability(of: vulpix, in: .Red), .tradeOnly)
        XCTAssertEqual(availability.findAvailability(of: alakazam, in: .Red), .tradeOnly)
        XCTAssertEqual(availability.findAvailability(of: 149, in: .Red), .shinyLocked)
        XCTAssertEqual(availability.findAvailability(of: 150, in: .Red), .unavailable)
        XCTAssertTrue(availability.isApproximate(.Scarlet))
        XCTAssertFalse(availability.isApproximate(.Red))
    }

    func test_pokemonFromLaterGenerations_areNeverAvailable_evenWithoutGameData() {
        let availability = makeAvailability()

        XCTAssertEqual(availability.findAvailability(of: snivy, in: .SoulSilver), .unavailable)
        XCTAssertEqual(availability.findAvailability(of: snivy, in: .Black), .catchable, "Games without data don't restrict released Pokémon")
        XCTAssertEqual(availability.findAvailability(of: wyrdeer, in: .UltraSun), .unavailable)
    }

    func test_gameChoices_hideUnavailableGames_butKeepTheCurrentOne() {
        let handler = GetGameChoicesHandler(availability: makeAvailability())

        let vulpixChoices = handler.handle(GetGameChoicesQuery(number: vulpix))
        XCTAssertEqual(vulpixChoices.first, GameChoice(game: .Red, availability: .tradeOnly, isApproximate: false))
        XCTAssertFalse(vulpixChoices.contains { $0.game == .Scarlet }, "Not in Scarlet's data")

        let snivyChoices = handler.handle(GetGameChoicesQuery(number: snivy, keeping: .SoulSilver))
        XCTAssertEqual(snivyChoices.first, GameChoice(game: .SoulSilver, availability: .unavailable, isApproximate: false))
        XCTAssertEqual(snivyChoices.dropFirst().first?.game, .Black)

        XCTAssertEqual(handler.handle(GetGameChoicesQuery(number: nil)).count, Games.allCases.count)
    }

    func test_bundledData_coversEveryGame_withKnownCases() throws {
        let availability = GameAvailabilityLoader.load(from: BundleResourceLoader(bundle: Bundle(for: AppContainer.self)))

        for game in Games.allCases {
            XCTAssertNotEqual(availability.findAvailability(of: bulbasaur, in: game), .unavailable, "Bulbasaur can exist in \(game)")
        }
        XCTAssertEqual(availability.findAvailability(of: 149, in: .Red), .catchable, "Mewtwo")
        XCTAssertEqual(availability.findAvailability(of: 150, in: .Red), .tradeOnly, "Mew")
        XCTAssertEqual(availability.findAvailability(of: alakazam, in: .Red), .tradeOnly, "Trade evolution")
        XCTAssertEqual(availability.findAvailability(of: vulpix, in: .Red), .tradeOnly, "Blue exclusive")
        XCTAssertEqual(availability.findAvailability(of: vulpix, in: .Blue), .catchable)
        XCTAssertEqual(availability.findAvailability(of: 171, in: .Gold), .catchable, "Pichu by breeding")
        XCTAssertEqual(availability.findAvailability(of: 888, in: .Sword), .shinyLocked, "Zamazenta can only come from its locked encounter in Shield")
        XCTAssertEqual(availability.findAvailability(of: chikorita, in: .LetsGoPikachu), .unavailable)
        XCTAssertTrue(availability.isApproximate(.Scarlet))
        XCTAssertEqual(availability.findAvailability(of: 643, in: .White), .shinyLocked, "Zekrom")
        XCTAssertEqual(availability.findAvailability(of: 643, in: .Black), .shinyLocked, "Zekrom can only be traded in from games where it's locked")
        XCTAssertEqual(availability.findAvailability(of: 643, in: .X), .tradeOnly, "Zekrom can be traded in from Alpha Sapphire")
        XCTAssertEqual(availability.findAvailability(of: 645, in: .Black), .catchable, "Kyurem isn't locked in Black")
        XCTAssertEqual(availability.findAvailability(of: 150, in: .Red), .tradeOnly, "Mew is event only, not locked")
        XCTAssertEqual(availability.findAvailability(of: 643, in: .Black2), .shinyLocked, "Zekrom")
        XCTAssertEqual(availability.findAvailability(of: 642, in: .White2), .shinyLocked, "Reshiram")
        XCTAssertEqual(availability.findAvailability(of: 493, in: .Black), .shinyLocked, "Victini")
        XCTAssertEqual(availability.findAvailability(of: 772, in: .Sun), .shinyLocked, "Silvally evolves from a locked Type: Null")
        XCTAssertEqual(availability.findAvailability(of: 20, in: .Gold), .catchable, "Spearow is wild too")
    }
}
