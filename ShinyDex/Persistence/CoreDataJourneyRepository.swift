import CoreData

final class CoreDataJourneyRepository: JourneyRepository {
    private static let identities = ManagedObjectIdentityMap<UUID>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "JourneyEntity", in: managedContext)!
    }

    func getAll() -> [Journey] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JourneyEntity")
        do {
            return try managedContext.fetch(fetchRequest).map(makeJourney)
        }
        catch let error as NSError {
            print("Could not fetch JourneyEntity table. \(error.localizedDescription)")
        }
        return []
    }

    @discardableResult
    func save(_ journey: Journey) -> Bool {
        let existing = object(for: journey.id)
        if let existing = existing, StoredJourneyEntry.hasUnreadableEntries(existing.value(forKey: "entries") as? String) {
            print("Refusing to save journey \(journey.id): its stored entries could not be read and would be overwritten.")
            return false
        }
        let journeyEntity = existing ?? insertEntity(for: journey)
        journeyEntity.setValue(journey.id, forKey: "id")
        journeyEntity.setValue(journey.name, forKey: "name")
        journeyEntity.setValue(journey.createdDate, forKey: "createdDate")
        journeyEntity.setValue(journey.priority, forKey: "priority")
        journeyEntity.setValue(StoredJourneyEntry.encode(journey.entries), forKey: "entries")
        return save()
    }

    func delete(_ journey: Journey) {
        guard let journeyEntity = object(for: journey.id) else { return }
        managedContext.delete(journeyEntity)
        save()
    }

    private func object(for id: UUID) -> NSManagedObject? {
        if let known = Self.identities.object(for: id, in: managedContext) {
            return known
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JourneyEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? managedContext.fetch(fetchRequest))?.first
    }

    private func insertEntity(for journey: Journey) -> NSManagedObject {
        let journeyEntity = managedContext.insertWithPermanentID(entity: entity)
        Self.identities.record(journey.id, for: journeyEntity.objectID)
        return journeyEntity
    }

    private func makeJourney(from journeyEntity: NSManagedObject) -> Journey {
        let id = journeyEntity.value(forKey: "id") as? UUID ?? Self.identities.key(for: journeyEntity.objectID) ?? UUID()
        Self.identities.record(id, for: journeyEntity.objectID)
        return Journey(
            id: id,
            name: journeyEntity.value(forKey: "name") as? String ?? "Journey",
            createdDate: journeyEntity.value(forKey: "createdDate") as? Date ?? Date(),
            priority: journeyEntity.value(forKey: "priority") as? Int ?? 0,
            entries: StoredJourneyEntry.decode(journeyEntity.value(forKey: "entries") as? String) ?? [])
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try managedContext.save()
            return true
        }
        catch let error as NSError {
            print("Could not save journeys. \(error.localizedDescription)")
            managedContext.rollback()
            return false
        }
    }
}

// The JSON stored in JourneyEntity.entries. Its keys are a stored format: renaming them would make existing journeys unreadable.
struct StoredJourneyEntry: Codable {
    let id: UUID
    let number: Int
    let catchId: UUID?
    let phaseCatchIds: [UUID]?

    static func encode(_ entries: [JourneyEntry]) -> String {
        let stored = entries.map { StoredJourneyEntry(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds.isEmpty ? nil : $0.phaseCatchIds) }
        let data = (try? JSONEncoder().encode(stored)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func decode(_ json: String?) -> [JourneyEntry]? {
        guard let json = json, !json.isEmpty else { return [] }
        guard let stored = try? JSONDecoder().decode([StoredJourneyEntry].self, from: Data(json.utf8)) else { return nil }
        return stored.map { JourneyEntry(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds ?? []) }
    }

    static func hasUnreadableEntries(_ json: String?) -> Bool {
        return decode(json) == nil
    }
}
