import CoreData

final class CoreDataMoveRepository: MoveRepository {
    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "ActiveMovesEntity", in: managedContext)!
    }

    func getActiveMoves() -> ActiveMoves? {
        guard let activeMovesEntity = fetchFirstEntity() else { return nil }
        return ActiveMoves(
            moves: StoredActiveMove.decode(activeMovesEntity.value(forKey: "json") as? String) ?? [],
            pressureActive: activeMovesEntity.value(forKey: "pressureActive") as? Bool ?? false)
    }

    func insert(_ activeMoves: ActiveMoves) {
        write(activeMoves, to: NSManagedObject(entity: entity, insertInto: managedContext))
    }

    func save(_ activeMoves: ActiveMoves) {
        guard let activeMovesEntity = fetchFirstEntity() else {
            insert(activeMoves)
            return
        }
        if StoredActiveMove.decode(activeMovesEntity.value(forKey: "json") as? String) == nil {
            print("Refusing to save active moves: the stored moves could not be read and would be overwritten.")
            return
        }
        write(activeMoves, to: activeMovesEntity)
    }

    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ActiveMovesEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        }
        catch let error as NSError {
            print("An error ocurred when deleting all entities: \(error.localizedDescription)")
        }
    }

    private func write(_ activeMoves: ActiveMoves, to activeMovesEntity: NSManagedObject) {
        activeMovesEntity.setValue(StoredActiveMove.encode(activeMoves.moves), forKey: "json")
        activeMovesEntity.setValue(activeMoves.pressureActive, forKey: "pressureActive")
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save active moves. \(error.localizedDescription)")
        }
    }

    private func fetchFirstEntity() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ActiveMovesEntity")
        do {
            return try managedContext.fetch(fetchRequest).first
        }
        catch let error as NSError {
            print("Could not fetch ActiveMovesEntity table. \(error.localizedDescription)")
        }
        return nil
    }
}

// The JSON stored in ActiveMovesEntity.json. Its keys are a stored format: renaming them would make saved moves unreadable.
struct StoredActiveMove: Codable {
    let name: String
    let maxPP: Int
    let remainingPP: Int
    let type: String

    static func encode(_ moves: [ActiveMove]) -> String {
        let stored = moves.map { StoredActiveMove(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) }
        let data = (try? JSONEncoder().encode(stored)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func decode(_ json: String?) -> [ActiveMove]? {
        guard let json = json, !json.isEmpty else { return [] }
        guard let stored = try? JSONDecoder().decode([StoredActiveMove].self, from: Data(json.utf8)) else { return nil }
        return stored.map { ActiveMove(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) }
    }
}
