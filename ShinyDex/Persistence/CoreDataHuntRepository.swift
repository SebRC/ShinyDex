import UIKit
import CoreData

final class CoreDataHuntRepository: HuntRepository {
    // HuntEntity has no id attribute yet, so hunts are matched to their rows only through this map.
    private static let identities = ManagedObjectIdentityMap<UUID>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
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
        let huntEntity = Self.identities.object(for: hunt.id, in: managedContext) ?? insertEntity(for: hunt)
        huntEntity.setValue(hunt.name, forKey: "name")
        huntEntity.setValue(hunt.indexes, forKey: "indexes")
        huntEntity.setValue(hunt.priority, forKey: "priority")
        huntEntity.setValue(hunt.isCollapsed, forKey: "isCollapsed")
        save()
    }

    func delete(_ hunt: Hunt) {
        guard let huntEntity = Self.identities.object(for: hunt.id, in: managedContext) else { return }
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

    private func insertEntity(for hunt: Hunt) -> NSManagedObject {
        let huntEntity = managedContext.insertWithPermanentID(entity: entity)
        Self.identities.record(hunt.id, for: huntEntity.objectID)
        return huntEntity
    }

    private func makeHunt(from huntEntity: NSManagedObject) -> Hunt {
        let id = Self.identities.key(for: huntEntity.objectID) ?? UUID()
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
