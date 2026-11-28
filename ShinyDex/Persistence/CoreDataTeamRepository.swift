import CoreData

final class CoreDataTeamRepository: TeamRepository {
    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "TeamEntity", in: managedContext)!
    }

    func getAll() -> [Team] {
        return fetch(predicate: nil).compactMap { teamEntity in
            guard let id = teamEntity.value(forKey: "id") as? UUID else { return nil }
            return Team(id: id,
                        name: teamEntity.value(forKey: "name") as? String ?? "",
                        memberIds: Team.decodeMembers(teamEntity.value(forKey: "memberIds") as? String),
                        createdDate: teamEntity.value(forKey: "createdDate") as? Date ?? Date(timeIntervalSince1970: 0))
        }
    }

    func save(_ team: Team) {
        let teamEntity = fetch(predicate: makeIdPredicate(team.id)).first ?? NSManagedObject(entity: entity, insertInto: managedContext)
        teamEntity.setValue(team.id, forKey: "id")
        teamEntity.setValue(team.name, forKey: "name")
        teamEntity.setValue(Team.encodeMembers(team.memberIds), forKey: "memberIds")
        teamEntity.setValue(team.createdDate, forKey: "createdDate")
        saveContext()
    }

    func delete(id: UUID) {
        fetch(predicate: makeIdPredicate(id)).forEach(managedContext.delete)
        saveContext()
    }

    private func makeIdPredicate(_ id: UUID) -> NSPredicate {
        return NSPredicate(format: "id == %@", id as CVarArg)
    }

    private func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save teams. \(error.localizedDescription)")
        }
    }

    private func fetch(predicate: NSPredicate?) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TeamEntity")
        fetchRequest.predicate = predicate
        do {
            return try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch TeamEntity table. \(error.localizedDescription)")
        }
        return []
    }
}
