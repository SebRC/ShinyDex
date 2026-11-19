import CoreData
@testable import ShinyDex

final class TestStore {
    static let modelDirectory = Bundle(for: AppDelegate.self).url(forResource: "ShinyDex", withExtension: "momd")!
    static let currentModel = NSManagedObjectModel(contentsOf: modelDirectory)!

    static func model(version: String) -> NSManagedObjectModel {
        return NSManagedObjectModel(contentsOf: modelDirectory.appendingPathComponent("\(version).mom"))!
    }

    let url: URL
    private(set) var container: NSPersistentContainer

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("ShinyDex.sqlite")
        container = try TestStore.openContainer(at: url)
    }

    // Opens a fresh container on the same file so reads come from disk, not from a context's cache.
    func reopen() throws {
        try closeStores()
        container = try TestStore.openContainer(at: url)
    }

    func destroy() throws {
        try closeStores()
        try FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    private func closeStores() throws {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            try coordinator.remove(store)
        }
    }

    // Mirrors the app's container: default store description options, which migrate automatically with an inferred mapping model,
    // followed by the same launch maintenance.
    static func openContainer(at url: URL) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "ShinyDex", managedObjectModel: currentModel)
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError = loadError {
            throw loadError
        }
        StoreMaintenance.run(in: container.viewContext)
        return container
    }
}
