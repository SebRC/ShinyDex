import CoreData

final class CoreDataCatchRepository: CatchRepository {
    private static let identities = ManagedObjectIdentityMap<UUID>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "CatchEntity", in: managedContext)!
    }

    func getAll() -> [Catch] {
        return fetch(predicate: nil).map(makeCatch)
    }

    func getAll(number: Int) -> [Catch] {
        return fetch(predicate: NSPredicate(format: "number == %d", number)).map(makeCatch)
    }

    func get(id: UUID) -> Catch? {
        return object(for: id).map(makeCatch)
    }

    func insert(_ caught: Catch) {
        let catchEntity = managedContext.insertWithPermanentID(entity: entity)
        write(caught, to: catchEntity)
        Self.identities.record(caught.id, for: catchEntity.objectID)
    }

    func update(_ caught: Catch) {
        if let catchEntity = object(for: caught.id) {
            write(caught, to: catchEntity)
        }
    }

    func delete(_ caught: Catch) {
        if let catchEntity = object(for: caught.id) {
            managedContext.delete(catchEntity)
        }
    }

    @discardableResult
    func save() -> Bool {
        do {
            try managedContext.save()
            return true
        }
        catch let error as NSError {
            print("Could not save catches. \(error.localizedDescription)")
            managedContext.rollback()
            return false
        }
    }

    private func object(for id: UUID) -> NSManagedObject? {
        if let known = Self.identities.object(for: id, in: managedContext) {
            return known
        }
        return fetch(predicate: NSPredicate(format: "id == %@", id as CVarArg)).first
    }

    private func makeCatch(from catchEntity: NSManagedObject) -> Catch {
        let id = catchEntity.value(forKey: "id") as? UUID ?? Self.identities.key(for: catchEntity.objectID) ?? UUID()
        Self.identities.record(id, for: catchEntity.objectID)
        let evolvedFrom = catchEntity.value(forKey: "evolvedFrom") as? Int ?? -1
        return Catch(
            id: id,
            number: catchEntity.value(forKey: "number") as? Int ?? 0,
            caughtBall: catchEntity.value(forKey: "caughtBall") as? String ?? CatchRules.noBall,
            game: Games(rawValue: catchEntity.value(forKey: "game") as? String ?? "") ?? Games.Red,
            huntMethod: HuntMethod(rawValue: catchEntity.value(forKey: "huntMethod") as? String ?? "") ?? HuntMethod.Encounters,
            encounters: catchEntity.value(forKey: "encounters") as? Int ?? 0,
            isShinyCharmActive: catchEntity.value(forKey: "isShinyCharmActive") as? Bool ?? false,
            caughtDate: catchEntity.value(forKey: "caughtDate") as? Date,
            isFailed: catchEntity.value(forKey: "isFailed") as? Bool ?? false,
            evs: EffortValues(encoded: catchEntity.value(forKey: "evs") as? String),
            evolvedFrom: evolvedFrom >= 0 ? evolvedFrom : nil)
    }

    private func write(_ caught: Catch, to catchEntity: NSManagedObject) {
        catchEntity.setValue(caught.id, forKey: "id")
        catchEntity.setValue(caught.number, forKey: "number")
        catchEntity.setValue(caught.caughtBall, forKey: "caughtBall")
        catchEntity.setValue(caught.game.rawValue, forKey: "game")
        catchEntity.setValue(caught.huntMethod.rawValue, forKey: "huntMethod")
        catchEntity.setValue(caught.encounters, forKey: "encounters")
        catchEntity.setValue(caught.isShinyCharmActive, forKey: "isShinyCharmActive")
        catchEntity.setValue(caught.caughtDate, forKey: "caughtDate")
        catchEntity.setValue(caught.isFailed, forKey: "isFailed")
        catchEntity.setValue(caught.evs.isEmpty ? nil : caught.evs.encoded, forKey: "evs")
        catchEntity.setValue(caught.evolvedFrom ?? -1, forKey: "evolvedFrom")
    }

    private func fetch(predicate: NSPredicate?) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CatchEntity")
        fetchRequest.predicate = predicate
        do {
            return try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch CatchEntity table. \(error.localizedDescription)")
        }
        return []
    }
}
