import CoreData

final class CoreDataYearlyGoalRepository: YearlyGoalRepository {
    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "YearlyGoalEntity", in: managedContext)!
    }

    func getAll() -> [YearlyGoal] {
        return fetch(predicate: nil)
            .map { YearlyGoal(year: $0.value(forKey: "year") as? Int ?? 0, target: $0.value(forKey: "target") as? Int ?? 0) }
            .sorted { $0.year < $1.year }
    }

    func save(_ goal: YearlyGoal) {
        let goalEntity = fetch(predicate: makeYearPredicate(goal.year)).first ?? NSManagedObject(entity: entity, insertInto: managedContext)
        goalEntity.setValue(goal.year, forKey: "year")
        goalEntity.setValue(goal.target, forKey: "target")
        saveContext()
    }

    func delete(year: Int) {
        fetch(predicate: makeYearPredicate(year)).forEach(managedContext.delete)
        saveContext()
    }

    private func makeYearPredicate(_ year: Int) -> NSPredicate {
        return NSPredicate(format: "year == %d", year)
    }

    private func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save yearly goals. \(error.localizedDescription)")
        }
    }

    private func fetch(predicate: NSPredicate?) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "YearlyGoalEntity")
        fetchRequest.predicate = predicate
        do {
            return try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch YearlyGoalEntity table. \(error.localizedDescription)")
        }
        return []
    }
}
