import CoreData

// Remembers which stored row a domain object was loaded from, so a row without a stored id can still be matched
// when the object is saved through another repository instance.
final class ManagedObjectIdentityMap<Key: Hashable> {
    private var objectIDsByKey = [Key: NSManagedObjectID]()
    private var keysByObjectID = [NSManagedObjectID: Key]()

    func getKey(for objectID: NSManagedObjectID) -> Key? {
        return keysByObjectID[objectID]
    }

    func record(_ key: Key, for objectID: NSManagedObjectID) {
        if let previousKey = keysByObjectID[objectID], previousKey != key {
            objectIDsByKey[previousKey] = nil
        }
        objectIDsByKey[key] = objectID
        keysByObjectID[objectID] = key
    }

    func getObject(for key: Key, in context: NSManagedObjectContext) -> NSManagedObject? {
        guard let objectID = objectIDsByKey[key],
              let store = objectID.persistentStore,
              context.persistentStoreCoordinator?.persistentStores.contains(store) == true,
              let object = try? context.existingObject(with: objectID),
              !object.isDeleted else {
            return nil
        }
        return object
    }
}

extension NSManagedObjectContext {
    // Inserted objects only get a stable ID once it is made permanent; a temporary ID stops resolving after the first save.
    func insertWithPermanentID(entity: NSEntityDescription) -> NSManagedObject {
        let object = NSManagedObject(entity: entity, insertInto: self)
        try? obtainPermanentIDs(for: [object])
        return object
    }
}
