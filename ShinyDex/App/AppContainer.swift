import Foundation

final class AppContainer {
    let coreDataStack: CoreDataStack
    let resourceLoader: ResourceLoader
    let keyValueStore: KeyValueStore
    let backupFolder: BackupFolder
    let gameAvailability: GameAvailability
    lazy var pokemonLocations = PokemonLocationsLoader.load(from: resourceLoader)
    lazy var learnsets = PokemonLearnsetsLoader.load(from: resourceLoader)
    let locationLinkProvider: LocationLinkProvider
    let evolutions: Evolutions
    let forms: PokemonForms
    let abilities: PokemonAbilities
    let bingoTemplates: BingoTemplates
    let ppPresets: PPPresets

    let pokemonRepository: PokemonRepository
    let catchRepository: CatchRepository
    let huntRepository: HuntRepository
    let journeyRepository: JourneyRepository
    let bingoBoardRepository: BingoBoardRepository
    let moveRepository: MoveRepository
    let encounterLedgerRepository: EncounterLedgerRepository
    let yearlyGoalRepository: YearlyGoalRepository
    let dailyEncountersRepository: DailyEncountersRepository
    let backupRepository: BackupRepository

    init(coreDataStack: CoreDataStack, resourceLoader: ResourceLoader, keyValueStore: KeyValueStore, locationLinkProvider: LocationLinkProvider, backupFolder: BackupFolder) {
        self.coreDataStack = coreDataStack
        self.backupFolder = backupFolder
        self.resourceLoader = resourceLoader
        self.keyValueStore = keyValueStore
        self.locationLinkProvider = locationLinkProvider
        evolutions = EvolutionsLoader.load(from: resourceLoader)
        forms = PokemonFormsLoader.load(from: resourceLoader)
        abilities = PokemonAbilitiesLoader.load(from: resourceLoader)
        ppPresets = PPPresetsLoader.load(from: resourceLoader)
        gameAvailability = GameAvailabilityLoader.load(from: resourceLoader)
        bingoTemplates = BingoTemplatesLoader.load(from: resourceLoader, pokemonNames: resourceLoader.loadLines(ofTextResource: "allGens"), forms: forms)

        let context = coreDataStack.viewContext
        pokemonRepository = CoreDataPokemonRepository(managedContext: context)
        catchRepository = CoreDataCatchRepository(managedContext: context)
        huntRepository = CoreDataHuntRepository(managedContext: context)
        journeyRepository = CoreDataJourneyRepository(managedContext: context)
        bingoBoardRepository = CoreDataBingoBoardRepository(managedContext: context)
        moveRepository = CoreDataMoveRepository(managedContext: context)
        encounterLedgerRepository = CoreDataEncounterLedgerRepository(managedContext: context)
        yearlyGoalRepository = CoreDataYearlyGoalRepository(managedContext: context)
        dailyEncountersRepository = CoreDataDailyEncountersRepository(managedContext: context)
        backupRepository = CoreDataBackupRepository(managedContext: context)
    }

    private let odds = OddsService()
    private let probability = ProbabilityService()

    // MARK: Pokémon

    var getPokemonDetails: GetPokemonDetailsHandler { GetPokemonDetailsHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, odds: odds, probability: probability) }
    var getAllPokemon: GetAllPokemonHandler { GetAllPokemonHandler(pokemonRepository: pokemonRepository) }
    var getPokedex: GetPokedexHandler { GetPokedexHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, availability: gameAvailability) }
    var getPokemonLocations: GetPokemonLocationsHandler { GetPokemonLocationsHandler(pokemonRepository: pokemonRepository, locations: pokemonLocations, availability: gameAvailability, evolutions: evolutions) }
    var getLocationsOverview: GetLocationsOverviewHandler { GetLocationsOverviewHandler(pokemonRepository: pokemonRepository, getPokemonLocations: getPokemonLocations, getGameChoices: getGameChoices) }
    var getGameChoices: GetGameChoicesHandler { GetGameChoicesHandler(availability: gameAvailability) }
    var previewHuntSettings: PreviewHuntSettingsHandler { PreviewHuntSettingsHandler(odds: odds) }
    var saveHuntSettings: SaveHuntSettingsHandler { SaveHuntSettingsHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var applyHuntSettingsToAll: ApplyHuntSettingsToAllHandler { ApplyHuntSettingsToAllHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var applyHuntSettingsToRegion: ApplyHuntSettingsToRegionHandler { ApplyHuntSettingsToRegionHandler(pokemonRepository: pokemonRepository, odds: odds) }
    var changeEncounters: ChangeEncountersHandler { ChangeEncountersHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, ledgerRepository: encounterLedgerRepository, dailyEncountersRepository: dailyEncountersRepository, odds: odds) }
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
    var getCatchDetails: GetCatchDetailsHandler { GetCatchDetailsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions, forms: forms, abilities: abilities, makeLearnsets: { [unowned self] in self.learnsets }) }
    var getCatchStatistics: GetCatchStatisticsHandler { GetCatchStatisticsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, ledgerRepository: encounterLedgerRepository, yearlyGoalRepository: yearlyGoalRepository, dailyEncountersRepository: dailyEncountersRepository, forms: forms) }
    var getBallNames: GetBallNamesHandler { GetBallNamesHandler(resourceLoader: resourceLoader) }
    var logCatch: LogCatchHandler { LogCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, ledgerRepository: encounterLedgerRepository, forms: forms) }
    var getLearnableMoves: GetLearnableMovesHandler { GetLearnableMovesHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, learnsets: learnsets) }
    var updateCatch: UpdateCatchHandler { UpdateCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms, abilities: abilities) }
    var evolveCatch: EvolveCatchHandler { EvolveCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms, abilities: abilities) }
    var deleteCatch: DeleteCatchHandler { DeleteCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var removeLatestCatch: RemoveLatestCatchHandler { RemoveLatestCatchHandler(catchRepository: catchRepository, deleteCatch: deleteCatch) }

    // MARK: Progress

    var getYearInReview: GetYearInReviewHandler { GetYearInReviewHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, yearlyGoalRepository: yearlyGoalRepository, dailyEncountersRepository: dailyEncountersRepository, forms: forms) }
    var getEncounterHistory: GetEncounterHistoryHandler { GetEncounterHistoryHandler(dailyEncountersRepository: dailyEncountersRepository) }
    var getEncounterDay: GetEncounterDayHandler { GetEncounterDayHandler(dailyEncountersRepository: dailyEncountersRepository, pokemonRepository: pokemonRepository) }
    var setYearlyGoal: SetYearlyGoalHandler { SetYearlyGoalHandler(yearlyGoalRepository: yearlyGoalRepository) }

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
    var getBingoTemplates: GetBingoTemplatesHandler { GetBingoTemplatesHandler(templates: bingoTemplates, pokemonRepository: pokemonRepository) }
    var createGeneratedBingoBoard: CreateGeneratedBingoBoardHandler { CreateGeneratedBingoBoardHandler(bingoBoardRepository: bingoBoardRepository, pokemonRepository: pokemonRepository, catchRepository: catchRepository, templates: bingoTemplates) }
    var updateBingoBoard: UpdateBingoBoardHandler { UpdateBingoBoardHandler(bingoBoardRepository: bingoBoardRepository) }
    var deleteBingoBoard: DeleteBingoBoardHandler { DeleteBingoBoardHandler(bingoBoardRepository: bingoBoardRepository) }

    // MARK: Moves

    var getActiveMoves: GetActiveMovesHandler { GetActiveMovesHandler(moveRepository: moveRepository) }
    var saveActiveMoves: SaveActiveMovesHandler { SaveActiveMovesHandler(moveRepository: moveRepository) }
    var getMoveOptions: GetMoveOptionsHandler { GetMoveOptionsHandler(resourceLoader: resourceLoader) }
    var getPPPresets: GetPPPresetsHandler { GetPPPresetsHandler(presets: ppPresets, getMoveOptions: getMoveOptions) }
    var applyPPPreset: ApplyPPPresetHandler { ApplyPPPresetHandler(presets: ppPresets, getMoveOptions: getMoveOptions, moveRepository: moveRepository) }

    // MARK: Backup

    var exportBackup: ExportBackupHandler { ExportBackupHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, huntRepository: huntRepository, journeyRepository: journeyRepository, bingoBoardRepository: bingoBoardRepository, moveRepository: moveRepository, ledgerRepository: encounterLedgerRepository, yearlyGoalRepository: yearlyGoalRepository, dailyEncountersRepository: dailyEncountersRepository) }
    var getBackupSummary: GetBackupSummaryHandler { GetBackupSummaryHandler() }
    var runAutomaticBackup: RunAutomaticBackupHandler { RunAutomaticBackupHandler(exportBackup: exportBackup, backupFolder: backupFolder, keyValueStore: keyValueStore) }
    var getAutomaticBackupStatus: GetAutomaticBackupStatusHandler { GetAutomaticBackupStatusHandler(backupFolder: backupFolder, keyValueStore: keyValueStore) }
    var chooseBackupFolder: ChooseBackupFolderHandler { ChooseBackupFolderHandler(backupFolder: backupFolder, keyValueStore: keyValueStore) }
    var turnOffAutomaticBackups: TurnOffAutomaticBackupsHandler { TurnOffAutomaticBackupsHandler(backupFolder: backupFolder, keyValueStore: keyValueStore) }
    var restoreBackup: RestoreBackupHandler { RestoreBackupHandler(backupRepository: backupRepository, pokemonRepository: pokemonRepository) }

    // MARK: Menu and startup

    var getOnThisDay: GetOnThisDayHandler { GetOnThisDayHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, forms: forms) }
    var getMenuSummary: GetMenuSummaryHandler { GetMenuSummaryHandler(getHunts: getHunts, getJourneys: getJourneys, getBingoBoards: getBingoBoards, catchRepository: catchRepository) }
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
            locationLinkProvider: SerebiiLocationLinkProvider(),
            backupFolder: BookmarkedBackupFolder())
    }
}
