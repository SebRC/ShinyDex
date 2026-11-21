import CoreData

final class CoreDataDailyEncountersRepository: DailyEncountersRepository {
    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "DailyEncounterEntity", in: managedContext)!
    }

    func get(day: EncounterDay) -> DailyEncounters? {
        return fetch(predicate: makeDayPredicate(day)).first.flatMap(makeDailyEncounters)
    }

    func getAll() -> [DailyEncounters] {
        return fetch(predicate: nil).compactMap(makeDailyEncounters).sorted { $0.day < $1.day }
    }

    func save(_ encounters: DailyEncounters) {
        let dayEntity = fetch(predicate: makeDayPredicate(encounters.day)).first ?? NSManagedObject(entity: entity, insertInto: managedContext)
        write(encounters, to: dayEntity)
        saveContext()
    }

    func replaceAll(with encounters: [DailyEncounters]) {
        fetch(predicate: nil).forEach(managedContext.delete)
        for dayEncounters in encounters {
            write(dayEncounters, to: NSManagedObject(entity: entity, insertInto: managedContext))
        }
        saveContext()
    }

    private func write(_ encounters: DailyEncounters, to dayEntity: NSManagedObject) {
        dayEntity.setValue(encounters.day.isoDate, forKey: "day")
        dayEntity.setValue(encounters.count, forKey: "count")
    }

    private func makeDailyEncounters(from dayEntity: NSManagedObject) -> DailyEncounters? {
        guard let day = EncounterDay(isoDate: dayEntity.value(forKey: "day") as? String) else { return nil }
        return DailyEncounters(day: day, count: dayEntity.value(forKey: "count") as? Int ?? 0)
    }

    private func makeDayPredicate(_ day: EncounterDay) -> NSPredicate {
        return NSPredicate(format: "day == %@", day.isoDate)
    }

    private func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save daily encounters. \(error.localizedDescription)")
        }
    }

    private func fetch(predicate: NSPredicate?) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DailyEncounterEntity")
        fetchRequest.predicate = predicate
        do {
            return try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch DailyEncounterEntity table. \(error.localizedDescription)")
        }
        return []
    }
}
