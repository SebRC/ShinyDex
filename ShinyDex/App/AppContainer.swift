import Foundation

final class AppContainer {
    let coreDataStack: CoreDataStack
    let resourceLoader: ResourceLoader
    let keyValueStore: KeyValueStore
    let locationLinkProvider: LocationLinkProvider
    let evolutions: Evolutions

    let pokemonRepository: PokemonRepository
    let catchRepository: CatchRepository
    let huntRepository: HuntRepository
    let journeyRepository: JourneyRepository
    let moveRepository: MoveRepository

    init(coreDataStack: CoreDataStack, resourceLoader: ResourceLoader, keyValueStore: KeyValueStore, locationLinkProvider: LocationLinkProvider) {
        self.coreDataStack = coreDataStack
        self.resourceLoader = resourceLoader
        self.keyValueStore = keyValueStore
        self.locationLinkProvider = locationLinkProvider
        evolutions = EvolutionsLoader.load(from: resourceLoader)

        let context = coreDataStack.viewContext
        pokemonRepository = CoreDataPokemonRepository(managedContext: context)
        catchRepository = CoreDataCatchRepository(managedContext: context)
        huntRepository = CoreDataHuntRepository(managedContext: context)
        journeyRepository = CoreDataJourneyRepository(managedContext: context)
        moveRepository = CoreDataMoveRepository(managedContext: context)
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
    var setIncrement: SetIncrementHandler { SetIncrementHandler(pokemonRepository: pokemonRepository) }
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

    var getCatches: GetCatchesHandler { GetCatchesHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var getCatchDetails: GetCatchDetailsHandler { GetCatchDetailsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions) }
    var getCatchStatistics: GetCatchStatisticsHandler { GetCatchStatisticsHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var getBallNames: GetBallNamesHandler { GetBallNamesHandler(resourceLoader: resourceLoader) }
    var logCatch: LogCatchHandler { LogCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var updateCatch: UpdateCatchHandler { UpdateCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var evolveCatch: EvolveCatchHandler { EvolveCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var deleteCatch: DeleteCatchHandler { DeleteCatchHandler(catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var removeLatestCatch: RemoveLatestCatchHandler { RemoveLatestCatchHandler(catchRepository: catchRepository, deleteCatch: deleteCatch) }

    // MARK: Journeys

    var getJourneys: GetJourneysHandler { GetJourneysHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository) }
    var getJourneyDetails: GetJourneyDetailsHandler { GetJourneyDetailsHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions) }
    var getLinkableCatches: GetLinkableCatchesHandler { GetLinkableCatchesHandler(journeyRepository: journeyRepository, catchRepository: catchRepository, pokemonRepository: pokemonRepository, evolutions: evolutions) }
    var createJourney: CreateJourneyHandler { CreateJourneyHandler(journeyRepository: journeyRepository) }
    var updateJourney: UpdateJourneyHandler { UpdateJourneyHandler(journeyRepository: journeyRepository) }
    var deleteJourney: DeleteJourneyHandler { DeleteJourneyHandler(journeyRepository: journeyRepository) }

    // MARK: Moves

    var getActiveMoves: GetActiveMovesHandler { GetActiveMovesHandler(moveRepository: moveRepository) }
    var saveActiveMoves: SaveActiveMovesHandler { SaveActiveMovesHandler(moveRepository: moveRepository) }
    var getMoveOptions: GetMoveOptionsHandler { GetMoveOptionsHandler(resourceLoader: resourceLoader) }

    // MARK: Menu and startup

    var getMenuSummary: GetMenuSummaryHandler { GetMenuSummaryHandler(getHunts: getHunts, getJourneys: getJourneys, catchRepository: catchRepository) }
    var prepareData: PrepareDataHandler { PrepareDataHandler(pokemonRepository: pokemonRepository, catchRepository: catchRepository, moveRepository: moveRepository, resourceLoader: resourceLoader, keyValueStore: keyValueStore) }

    static func live() -> AppContainer {
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
