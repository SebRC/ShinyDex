import CoreData

enum StoreMaintenance {
    // Data fixes that must run on every launch once the store has loaded, before the app reads from it.
    static func run(in context: NSManagedObjectContext) {
        CoreDataHuntRepository.assignMissingIds(in: context)
        CoreDataPokemonRepository.assignMissingChains(in: context)
    }
}
