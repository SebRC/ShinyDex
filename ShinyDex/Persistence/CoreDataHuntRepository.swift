import CoreData

final class CoreDataHuntRepository: HuntRepository {
    private static let identities = ManagedObjectIdentityMap<UUID>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "HuntEntity", in: managedContext)!
    }

    func getAll() -> [Hunt] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HuntEntity")
        do {
            return try managedContext.fetch(fetchRequest).map(makeHunt)
        }
        catch let error as NSError {
            print("Could not fetch HuntEntity table. \(error.localizedDescription)")
        }
        return []
    }

    func save(_ hunt: Hunt) {
        let huntEntity = object(for: hunt.id) ?? insertEntity(for: hunt)
        huntEntity.setValue(hunt.id, forKey: "id")
        huntEntity.setValue(hunt.name, forKey: "name")
        huntEntity.setValue(hunt.indexes, forKey: "indexes")
        huntEntity.setValue(hunt.priority, forKey: "priority")
        huntEntity.setValue(hunt.isCollapsed, forKey: "isCollapsed")
        save()
    }

    func delete(_ hunt: Hunt) {
        guard let huntEntity = object(for: hunt.id) else { return }
        managedContext.delete(huntEntity)
        save()
    }

    func clear() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "HuntEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        }
        catch let error as NSError {
            print("Could not clear table. \(error.localizedDescription)")
        }
        save()
    }

    // Must run once the store has loaded, before anything reads hunts.
    static func assignMissingIds(in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HuntEntity")
        fetchRequest.predicate = NSPredicate(format: "id == nil")
        guard let huntsWithoutId = try? context.fetch(fetchRequest), !huntsWithoutId.isEmpty else { return }
        for huntEntity in huntsWithoutId {
            huntEntity.setValue(UUID(), forKey: "id")
        }
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Could not assign hunt ids. \(error.localizedDescription)")
            context.rollback()
        }
    }

    private func object(for id: UUID) -> NSManagedObject? {
        if let known = Self.identities.object(for: id, in: managedContext) {
            return known
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HuntEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? managedContext.fetch(fetchRequest))?.first
    }

    private func insertEntity(for hunt: Hunt) -> NSManagedObject {
        let huntEntity = managedContext.insertWithPermanentID(entity: entity)
        Self.identities.record(hunt.id, for: huntEntity.objectID)
        return huntEntity
    }

    private func makeHunt(from huntEntity: NSManagedObject) -> Hunt {
        let id = huntEntity.value(forKey: "id") as? UUID ?? Self.identities.key(for: huntEntity.objectID) ?? UUID()
        Self.identities.record(id, for: huntEntity.objectID)
        return Hunt(
            id: id,
            name: huntEntity.value(forKey: "name") as! String,
            indexes: huntEntity.value(forKey: "indexes") as! [Int],
            priority: huntEntity.value(forKey: "priority") as! Int,
            isCollapsed: huntEntity.value(forKey: "isCollapsed") as! Bool)
    }

    private func save() {
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error.localizedDescription)")
        }
    }
}
