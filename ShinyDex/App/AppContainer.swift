import Foundation

final class AppContainer {
    let coreDataStack: CoreDataStack
    let resourceLoader: ResourceLoader
    let keyValueStore: KeyValueStore
    let locationLinkProvider: LocationLinkProvider
    let evolutions: Evolutions
    let forms: PokemonForms

    let pokemonRepository: PokemonRepository
    let catchRepository: CatchRepository
    let huntRepository: HuntRepository
    let journeyRepository: JourneyRepository
    let bingoBoardRepository: BingoBoardRepository
    let moveRepository: MoveRepository
    let backupRepository: BackupRepository

    init(coreDataStack: CoreDataStack, resourceLoader: ResourceLoader, keyValueStore: KeyValueStore, locationLinkProvider: LocationLinkProvider) {
        self.coreDataStack = coreDataStack
        self.resourceLoader = resourceLoader
        self.keyValueStore = keyValueStore
        self.locationLinkProvider = locationLinkProvider
        evolutions = EvolutionsLoader.load(from: resourceLoader)
        forms = PokemonFormsLoader.load(from: resourceLoader)

        let context = coreDataStack.viewContext
        pokemonRepository = CoreDataPokemonRepository(managedContext: context)
        catchRepository = CoreDataCatchRepository(managedContext: context)
        huntRepository = CoreDataHuntRepository(managedContext: context)
        journeyRepository = CoreDataJourneyRepository(managedContext: context)
        bingoBoardRepository = CoreDataBingoBoardRepository(managedContext: context)
        moveRepository = CoreDataMoveRepository(managedContext: context)
        backupRepository = CoreDataBackupRepository(managedContext: context)
    }

    private let odds = OddsService()
    private let probability = ProbabilityService()

    // MARK: Pokémon

    var getPokemonDetails: GetPokemonDetailsHandler { GetPokemonDetailsHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, odds: odds, probability: probability) }
    var getAllPokemon: GetAllPokemonHandler { GetAllPokemonHandler(pokemonRepository: pokemonRepository) }
    var getPokedex: GetPokedexHandler { GetPokedexHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository) }
    var previewHuntSettings: PreviewHuntSettingsHandler { PreviewHuntSettingsHandler(odds: odds) }
    var saveHuntSettings: SaveHuntSettingsHandler { SaveHuntSettingsHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var applyHuntSettingsToAll: ApplyHuntSettingsToAllHandler { ApplyHuntSettingsToAllHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var changeEncounters: ChangeEncountersHandler { ChangeEncountersHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var changeChain: ChangeChainHandler { ChangeChainHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var setIncrement: SetIncrementHandler { SetIncrementHandler(pokemonRepository: pokemonRepository) }
    var getPokemonForms: GetPokemonFormsHandler { GetPokemonFormsHandler(forms: forms) }
    var simulateOdds: SimulateOddsHandler { SimulateOddsHandler(odds: odds, probability: probability) }
    var getLocationLink: GetLocationLinkHandler { GetLocationLinkHandler(pokemonRepository: pokemonRepository, locationLinkProvider: locationLinkProvider) }

    // MARK: Hunts

    var getHunts: GetHuntsHandler { GetHuntsHandler(huntRepository: huntRepository, pokemonRepository: pokemonRepository) }
    var createHunt: CreateHuntHandler { CreateHuntHandler(huntRepository: huntRepository, pokemonRepository: pokemonRepository) }
    var addPokemonToHunt: AddPokemonToHuntHandler { AddPokemonToHuntHandler(huntRepository: huntRepository, pokemonRepository: pokemonRepository) }
    var updateHunt: UpdateHuntHandler { UpdateHuntHandler(huntRepository: huntRepository) }
    var incrementAllInHunt: IncrementAllInHuntHandler { IncrementAllInHuntHandler(huntRepository: huntRepository, changeEncounters: changeEncounters) }
    var removePokemonFromHunt: RemovePokemonFromHuntHandler { RemovePokemonFromHuntHandler(huntRepository: huntRepository, pokemonRepository: pokemonRepository) }
    var reorderHunts: ReorderHuntsHandler { ReorderHuntsHandler(huntRepository: huntRepository) }
    var clearHunts: ClearHuntsHandler { ClearHuntsHandler(huntRepository: huntRepository, pokemonRepository: pokemonRepository) }

    // MARK: Catches

    var getCatches: GetCatchesHandler { GetCatchesHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var getCatchDetails: GetCatchDetailsHandler { GetCatchDetailsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms) }
    var getCatchStatistics: GetCatchStatisticsHandler { GetCatchStatisticsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var getBallNames: GetBallNamesHandler { GetBallNamesHandler(resourceLoader: resourceLoader) }
    var logCatch: LogCatchHandler { LogCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var updateCatch: UpdateCatchHandler { UpdateCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var evolveCatch: EvolveCatchHandler { EvolveCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var deleteCatch: DeleteCatchHandler { DeleteCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var removeLatestCatch: RemoveLatestCatchHandler { RemoveLatestCatchHandler(catchRepository: catchRepository, deleteCatch: deleteCatch) }

    // MARK: Journeys

    var getJourneys: GetJourneysHandler { GetJourneysHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var getJourneyDetails: GetJourneyDetailsHandler { GetJourneyDetailsHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms) }
    var getLinkableCatches: GetLinkableCatchesHandler { GetLinkableCatchesHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms) }
    var createJourney: CreateJourneyHandler { CreateJourneyHandler(journeyRepository: journeyRepository) }
    var updateJourney: UpdateJourneyHandler { UpdateJourneyHandler(journeyRepository: journeyRepository) }
    var deleteJourney: DeleteJourneyHandler { DeleteJourneyHandler(journeyRepository: journeyRepository) }

    // MARK: Bingo

    var getBingoBoards: GetBingoBoardsHandler { GetBingoBoardsHandler(bingoBoardRepository: bingoBoardRepository, catchRepository: catchRepository) }
    var getBingoBoardDetails: GetBingoBoardDetailsHandler { GetBingoBoardDetailsHandler(bingoBoardRepository: bingoBoardRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms) }
    var getLinkableBingoCatches: GetLinkableBingoCatchesHandler { GetLinkableBingoCatchesHandler(bingoBoardRepository: bingoBoardRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms) }
    var createBingoBoard: CreateBingoBoardHandler { CreateBingoBoardHandler(bingoBoardRepository: bingoBoardRepository) }
    var updateBingoBoard: UpdateBingoBoardHandler { UpdateBingoBoardHandler(bingoBoardRepository: bingoBoardRepository) }
    var deleteBingoBoard: DeleteBingoBoardHandler { DeleteBingoBoardHandler(bingoBoardRepository: bingoBoardRepository) }

    // MARK: Moves

    var getActiveMoves: GetActiveMovesHandler { GetActiveMovesHandler(moveRepository: moveRepository) }
    var saveActiveMoves: SaveActiveMovesHandler { SaveActiveMovesHandler(moveRepository: moveRepository) }
    var getMoveOptions: GetMoveOptionsHandler { GetMoveOptionsHandler(resourceLoader: resourceLoader) }

    // MARK: Backup

    var exportBackup: ExportBackupHandler { ExportBackupHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, huntRepository: huntRepository, journeyRepository: journeyRepository, bingoBoardRepository: bingoBoardRepository, moveRepository: moveRepository) }
    var getBackupSummary: GetBackupSummaryHandler { GetBackupSummaryHandler() }
    var restoreBackup: RestoreBackupHandler { RestoreBackupHandler(backupRepository: backupRepository, pokemonRepository: pokemonRepository) }

    // MARK: Menu and startup

    var getMenuSummary: GetMenuSummaryHandler { GetMenuSummaryHandler(getHunts: getHunts, getJourneys: getJourneys, getBingoBoards: getBingoBoards, getCatches: getCatches, catchRepository: catchRepository) }
    var prepareData: PrepareDataHandler { PrepareDataHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, moveRepository: moveRepository, resourceLoader: resourceLoader, keyValueStore: keyValueStore) }

    static func makeLive() -> AppContainer {
        let coreDataStack: CoreDataStack
        do {
            coreDataStack = try CoreDataStack()
        }
        catch let error as NSError {
            // Failing loudly keeps the user's store untouched; recovering by recreating it would lose their data.
            fatalError("Could not load the persistent store: \(error), \(error.userInfo)")
        }
        return AppContainer(
            coreDataStack: coreDataStack,
            resourceLoader: BundleResourceLoader(),
            keyValueStore: UserDefaultsStore(),
            locationLinkProvider: SerebiiLocationLinkProvider())
    }
}
