import CoreData
@testable import ShinyDex

final class TestStore {
    static let modelDirectory = Bundle(for: AppDelegate.self).url(forResource: "ShinyDex", withExtension: "momd")!
    static let currentModel = NSManagedObjectModel(contentsOf: modelDirectory)!

    static func model(version: String) -> NSManagedObjectModel {
        return NSManagedObjectModel(contentsOf: modelDirectory.appendingPathComponent("\(version).mom"))!
    }

    let url: URL
    private(set) var stack: CoreDataStack

    var context: NSManagedObjectContext {
        return stack.viewContext
    }

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("ShinyDex.sqlite")
        stack = try TestStore.openStack(at: url)
    }

    // Opens a fresh stack on the same file so reads come from disk, not from a context's cache.
    func reopen() throws {
        try stack.close()
        stack = try TestStore.openStack(at: url)
    }

    func destroy() throws {
        try stack.close()
        try FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    static func openStack(at url: URL) throws -> CoreDataStack {
        return try CoreDataStack(storeURL: url, model: currentModel)
    }
}
