import XCTest
import UIKit
@testable import ShinyDex

final class PokemonFormsTests: XCTestCase {
    private let vulpix = 36
    private let ninetales = 37
    private let meowth = 51
    private let persian = 52
    private let gastrodon = 422

    private var pokemon: InMemoryPokemonRepository!
    private var catches: InMemoryCatchRepository!
    private var journeys: InMemoryJourneyRepository!
    private var bingoBoards: InMemoryBingoBoardRepository!
    private var forms: PokemonForms!
    private var evolutions: Evolutions!

    override func setUpWithError() throws {
        let loader = BundleResourceLoader(bundle: Bundle(for: AppDelegate.self))
        forms = PokemonFormsLoader.load(from: loader)
        evolutions = EvolutionsLoader.load(from: loader)
        pokemon = InMemoryPokemonRepository(names: loader.loadLines(ofTextResource: "allGens"))
        catches = InMemoryCatchRepository()
        journeys = InMemoryJourneyRepository()
        bingoBoards = InMemoryBingoBoardRepository()
    }

    private func logCatch(_ number: Int, formId: String? = nil) -> Catch {
        LogCatchHandler(catchRepository: catches, pokemonRepository: pokemon, ledgerRepository: InMemoryEncounterLedgerRepository(), forms: forms)
            .handle(LogCatchCommand(number: number, outcome: .caught(ball: "poke"), date: Date(), formId: formId))
        return catches.getAll().last!
    }

    // MARK: Catalog

    func test_bundledCatalog_listsRegionalAndCosmeticForms() throws {
        XCTAssertEqual(forms.findForm("alola", of: vulpix)?.name, "Alolan")
        let gastrodonForms = try XCTUnwrap(forms.getForms(of: gastrodon))
        XCTAssertEqual(gastrodonForms.defaultName, "West Sea")
        XCTAssertEqual(gastrodonForms.alternates.map { $0.name }, ["East Sea"])
        XCTAssertNil(forms.getForms(of: 0), "Bulbasaur has no alternate forms")
    }

    func test_bundledCatalog_leavesOutBattleOnlyForms() {
        let allIds = (0..<1010).compactMap { forms.getForms(of: $0) }.flatMap { $0.alternates.map { $0.id } }
        XCTAssertFalse(allIds.contains { $0.contains("mega") || $0.contains("gmax") || $0 == "zen" || $0 == "primal" })
    }

    func test_everyForm_hasASmallAndALargeSprite() {
        let names = BundleResourceLoader(bundle: Bundle(for: AppDelegate.self)).loadLines(ofTextResource: "allGens")
        for number in names.indices {
            for form in forms.getForms(of: number)?.alternates ?? [] {
                XCTAssertNotNil(UIImage(named: "\(names[number].lowercased())-\(form.id)"), "Missing small sprite for \(names[number]) \(form.id)")
                XCTAssertNotNil(NSDataAsset(name: "\(names[number])-\(form.id)"), "Missing large sprite for \(names[number]) \(form.id)")
            }
        }
    }

    func test_centeringVisiblePixels_movesASpriteStandingInACornerToTheMiddle() throws {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let sprite = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 6, width: 4, height: 4))
        }

        let centered = sprite.centeringVisiblePixels()

        XCTAssertEqual(centered.size, sprite.size)
        let pixels = try XCTUnwrap(centered.cgImage?.dataProvider?.data as Data?)
        let bytesPerRow = try XCTUnwrap(centered.cgImage?.bytesPerRow)
        let opaqueRows = (0..<10).filter { row in (0..<10).contains { column in pixels[row * bytesPerRow + column * 4 + 3] > 0 } }
        let opaqueColumns = (0..<10).filter { column in (0..<10).contains { row in pixels[row * bytesPerRow + column * 4 + 3] > 0 } }
        XCTAssertEqual(opaqueRows, [3, 4, 5, 6])
        XCTAssertEqual(opaqueColumns, [3, 4, 5, 6])
    }

    func test_fillingWithVisiblePixels_enlargesASmallSpriteUpToTheMaximumScale_andCentersIt() throws {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let sprite = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 8, width: 2, height: 2))
        }

        let filled = sprite.fillingWithVisiblePixels(fraction: 0.8, maximumScale: 3)

        XCTAssertEqual(filled.size, sprite.size)
        let cgImage = try XCTUnwrap(filled.cgImage)
        let pixels = try XCTUnwrap(cgImage.dataProvider?.data as Data?)
        let opaqueColumns = (0..<cgImage.width).filter { column in (0..<cgImage.height).contains { row in pixels[row * cgImage.bytesPerRow + column * 4 + 3] > 0 } }
        let opaqueRows = (0..<cgImage.height).filter { row in (0..<cgImage.width).contains { column in pixels[row * cgImage.bytesPerRow + column * 4 + 3] > 0 } }
        let pixelsPerPoint = filled.scale
        XCTAssertEqual(CGFloat(opaqueColumns.count) / pixelsPerPoint, 6, accuracy: 0.01)
        XCTAssertEqual(CGFloat(opaqueRows.count) / pixelsPerPoint, 6, accuracy: 0.01)
        XCTAssertEqual(CGFloat(try XCTUnwrap(opaqueColumns.first)) / pixelsPerPoint, 2, accuracy: 0.01)
        XCTAssertEqual(CGFloat(try XCTUnwrap(opaqueRows.first)) / pixelsPerPoint, 2, accuracy: 0.01)
    }

    func test_carryOver_keepsAFormTheTargetSpeciesHas_andDropsOthers() {
        XCTAssertEqual(forms.carryOver("alola", to: ninetales), "alola")
        XCTAssertNil(forms.carryOver("galar", to: persian))
        XCTAssertNil(forms.carryOver(nil, to: ninetales))
    }

    // MARK: Catches

    func test_loggingACatch_storesAKnownForm_andIgnoresAnUnknownOne() {
        XCTAssertEqual(logCatch(vulpix, formId: "alola").formId, "alola")
        XCTAssertNil(logCatch(vulpix, formId: "galar").formId)
    }

    func test_updatingTheForm_changesIt_andTheSummaryNamesIt() throws {
        let caught = logCatch(gastrodon)
        try UpdateCatchHandler(catchRepository: catches, pokemonRepository: pokemon, forms: forms)
            .handle(UpdateCatchCommand(catchId: CatchID(rawValue: caught.id), change: .form("east")))

        let details = try XCTUnwrap(GetCatchDetailsHandler(catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions, forms: forms)
            .handle(GetCatchDetailsQuery(catchId: CatchID(rawValue: caught.id))))
        XCTAssertEqual(details.summary.formId, "east")
        XCTAssertEqual(details.summary.formName, "East Sea")
        XCTAssertEqual(details.formChoices?.defaultName, "West Sea")
        XCTAssertEqual(details.formChoices?.findName(of: nil), "West Sea")
    }

    func test_evolvingACatch_carriesItsFormOverWhenTheEvolutionHasIt() throws {
        let alolanVulpix = logCatch(vulpix, formId: "alola")
        let galarianMeowth = logCatch(meowth, formId: "galar")
        let evolve = EvolveCatchHandler(catchRepository: catches, pokemonRepository: pokemon, forms: forms)

        try evolve.handle(EvolveCatchCommand(catchId: CatchID(rawValue: alolanVulpix.id), targetNumber: ninetales))
        try evolve.handle(EvolveCatchCommand(catchId: CatchID(rawValue: galarianMeowth.id), targetNumber: persian))

        XCTAssertEqual(catches.get(id: alolanVulpix.id)?.formId, "alola")
        XCTAssertNil(catches.get(id: galarianMeowth.id)?.formId)
    }

    // MARK: Journeys

    func test_journeyEntryWithAForm_onlyLinksCatchesOfThatForm() throws {
        let regular = logCatch(vulpix)
        let alolan = logCatch(ninetales, formId: "alola")
        let journey = Journey(name: "Alola", priority: 0, numbers: [vulpix])
        journeys.save(journey)
        let entryId = JourneyEntryID(rawValue: journey.entries[0].id)
        let update = UpdateJourneyHandler(journeyRepository: journeys)
        let linkable = GetLinkableCatchesHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions, forms: forms)

        XCTAssertEqual(Set(linkable.handle(GetLinkableCatchesQuery(journeyId: JourneyID(rawValue: journey.id), entryId: entryId)).map { $0.id.rawValue }), [regular.id, alolan.id])

        update.handle(UpdateJourneyCommand(journeyId: JourneyID(rawValue: journey.id), change: .setForm(entry: entryId, formId: "alola")))

        let linkableAlolan = linkable.handle(GetLinkableCatchesQuery(journeyId: JourneyID(rawValue: journey.id), entryId: entryId))
        XCTAssertEqual(linkableAlolan.map { $0.id.rawValue }, [alolan.id])
        let details = try XCTUnwrap(GetJourneyDetailsHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions, forms: forms)
            .handle(GetJourneyDetailsQuery(journeyId: JourneyID(rawValue: journey.id))))
        XCTAssertEqual(details.entries[0].formName, "Alolan")
    }

    func test_changingAJourneyEntrysForm_unlinksItsCatch() {
        let regular = logCatch(vulpix)
        let journey = Journey(name: "Alola", priority: 0, numbers: [vulpix])
        journey.entries[0].catchId = regular.id

        journey.setForm("alola", ofEntry: journey.entries[0].id)

        XCTAssertNil(journey.entries[0].catchId)
        XCTAssertEqual(journey.entries[0].formId, "alola")
    }

    // MARK: Bingo

    func test_bingoSquareWithAForm_onlyCountsCatchesOfThatForm() throws {
        let regular = logCatch(gastrodon)
        let board = BingoBoard(name: "Seas", priority: 0, size: .three, numbers: [gastrodon])
        board.link(regular.id, at: 0)
        bingoBoards.save(board)

        UpdateBingoBoardHandler(bingoBoardRepository: bingoBoards).handle(UpdateBingoBoardCommand(boardId: BingoBoardID(rawValue: board.id), change: .setForm(at: 0, formId: "east")))

        let details = try XCTUnwrap(GetBingoBoardDetailsHandler(bingoBoardRepository: bingoBoards, catchRepository: catches, pokemonRepository: pokemon, evolutions: evolutions, forms: forms)
            .handle(GetBingoBoardDetailsQuery(boardId: BingoBoardID(rawValue: board.id))))
        XCTAssertNil(details.cells[0].linkedCatch)
        XCTAssertEqual(details.cells[0].linkableCatchCount, 0)
        XCTAssertEqual(details.cells[0].formName, "East Sea")
    }
}
