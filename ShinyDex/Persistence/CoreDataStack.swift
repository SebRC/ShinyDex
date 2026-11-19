import CoreData

final class CoreDataStack {
    static let modelName = "ShinyDex"

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    // A nil storeURL uses the default location. The app relies on that: a different name or location would open a new, empty store.
    init(storeURL: URL? = nil, model: NSManagedObjectModel? = nil) throws {
        if let model = model {
            container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: CoreDataStack.modelName)
        }
        if let storeURL = storeURL {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError = loadError {
            throw loadError
        }
        StoreMaintenance.run(in: container.viewContext)
    }

    func saveIfNeeded() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        }
        catch let error as NSError {
            print("Could not save pending changes. \(error), \(error.userInfo)")
        }
    }

    func close() throws {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            try coordinator.remove(store)
        }
    }
}
