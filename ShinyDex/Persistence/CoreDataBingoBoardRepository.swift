import CoreData

final class CoreDataBingoBoardRepository: BingoBoardRepository {
    private static let identities = ManagedObjectIdentityMap<UUID>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "BingoBoardEntity", in: managedContext)!
    }

    func getAll() -> [BingoBoard] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BingoBoardEntity")
        do {
            return try managedContext.fetch(fetchRequest).map(makeBoard)
        }
        catch let error as NSError {
            print("Could not fetch BingoBoardEntity table. \(error.localizedDescription)")
        }
        return []
    }

    @discardableResult
    func save(_ board: BingoBoard) -> Bool {
        let existing = fetchObject(for: board.id)
        if let existing = existing, StoredBingoCell.hasUnreadableCells(existing.value(forKey: "cells") as? String) {
            print("Refusing to save bingo board \(board.id): its stored cells could not be read and would be overwritten.")
            return false
        }
        let boardEntity = existing ?? insertEntity(for: board)
        boardEntity.setValue(board.id, forKey: "id")
        boardEntity.setValue(board.name, forKey: "name")
        boardEntity.setValue(board.createdDate, forKey: "createdDate")
        boardEntity.setValue(board.priority, forKey: "priority")
        boardEntity.setValue(board.size.rawValue, forKey: "size")
        boardEntity.setValue(StoredBingoCell.encode(board.cells), forKey: "cells")
        return save()
    }

    func delete(_ board: BingoBoard) {
        guard let boardEntity = fetchObject(for: board.id) else { return }
        managedContext.delete(boardEntity)
        save()
    }

    private func fetchObject(for id: UUID) -> NSManagedObject? {
        if let known = Self.identities.getObject(for: id, in: managedContext) {
            return known
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BingoBoardEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? managedContext.fetch(fetchRequest))?.first
    }

    private func insertEntity(for board: BingoBoard) -> NSManagedObject {
        let boardEntity = managedContext.insertWithPermanentID(entity: entity)
        Self.identities.record(board.id, for: boardEntity.objectID)
        return boardEntity
    }

    private func makeBoard(from boardEntity: NSManagedObject) -> BingoBoard {
        let id = boardEntity.value(forKey: "id") as? UUID ?? Self.identities.getKey(for: boardEntity.objectID) ?? UUID()
        Self.identities.record(id, for: boardEntity.objectID)
        return BingoBoard(
            id: id,
            name: boardEntity.value(forKey: "name") as? String ?? "Bingo",
            createdDate: boardEntity.value(forKey: "createdDate") as? Date ?? Date(),
            priority: boardEntity.value(forKey: "priority") as? Int ?? 0,
            size: (boardEntity.value(forKey: "size") as? Int).flatMap(BingoBoardSize.init) ?? .five,
            cells: StoredBingoCell.decode(boardEntity.value(forKey: "cells") as? String) ?? [])
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try managedContext.save()
            return true
        }
        catch let error as NSError {
            print("Could not save bingo boards. \(error.localizedDescription)")
            managedContext.rollback()
            return false
        }
    }
}

struct StoredBingoCell: Codable {
    let number: Int?
    let catchId: UUID?

    static func encode(_ cells: [BingoCell]) -> String {
        let stored = cells.map { StoredBingoCell(number: $0.number, catchId: $0.catchId) }
        let data = (try? JSONEncoder().encode(stored)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    static func decode(_ json: String?) -> [BingoCell]? {
        guard let json = json, !json.isEmpty else { return [] }
        guard let stored = try? JSONDecoder().decode([StoredBingoCell].self, from: Data(json.utf8)) else { return nil }
        return stored.map { BingoCell(number: $0.number, catchId: $0.catchId) }
    }

    static func hasUnreadableCells(_ json: String?) -> Bool {
        return decode(json) == nil
    }
}
