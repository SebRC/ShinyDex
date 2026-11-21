import CoreData

final class CoreDataEncounterLedgerRepository: EncounterLedgerRepository {
    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "EncounterLedgerEntity", in: managedContext)!
    }

    func get() -> EncounterLedger? {
        guard let ledgerEntity = fetchFirstEntity(), let trackedSince = ledgerEntity.value(forKey: "trackedSince") as? Date else { return nil }
        return EncounterLedger(total: ledgerEntity.value(forKey: "total") as? Int ?? 0, trackedSince: trackedSince)
    }

    func save(_ ledger: EncounterLedger) {
        let ledgerEntity = fetchFirstEntity() ?? NSManagedObject(entity: entity, insertInto: managedContext)
        ledgerEntity.setValue(ledger.total, forKey: "total")
        ledgerEntity.setValue(ledger.trackedSince, forKey: "trackedSince")
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save the encounter ledger. \(error.localizedDescription)")
        }
    }

    private func fetchFirstEntity() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EncounterLedgerEntity")
        do {
            return try managedContext.fetch(fetchRequest).first
        }
        catch let error as NSError {
            print("Could not fetch EncounterLedgerEntity table. \(error.localizedDescription)")
        }
        return nil
    }
}
