import Foundation

final class AppContainer {
    // Transitional: lets code not yet given the container reach it. Removed once every screen is injected.
    static var shared: AppContainer!

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
