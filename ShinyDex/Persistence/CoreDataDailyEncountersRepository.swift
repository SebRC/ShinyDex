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
        dayEntity.setValue(CoreDataDailyEncountersRepository.encode(encounters.countsByPokemon), forKey: "pokemonCounts")
    }

    private static func encode(_ countsByPokemon: [Int: Int]) -> String? {
        guard !countsByPokemon.isEmpty else { return nil }
        let keyedByText = Dictionary(uniqueKeysWithValues: countsByPokemon.map { (String($0.key), $0.value) })
        return (try? JSONEncoder().encode(keyedByText)).flatMap { String(data: $0, encoding: .utf8) }
    }

    private static func decode(_ text: String?) -> [Int: Int] {
        guard let data = text?.data(using: .utf8), let keyedByText = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: keyedByText.compactMap { key, value in Int(key).map { ($0, value) } })
    }

    private func makeDailyEncounters(from dayEntity: NSManagedObject) -> DailyEncounters? {
        guard let day = EncounterDay(isoDate: dayEntity.value(forKey: "day") as? String) else { return nil }
        return DailyEncounters(day: day, count: dayEntity.value(forKey: "count") as? Int ?? 0,
                               countsByPokemon: CoreDataDailyEncountersRepository.decode(dayEntity.value(forKey: "pokemonCounts") as? String))
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
