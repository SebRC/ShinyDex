import Foundation
import UIKit
import CoreData

class CatchRepository {
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription

	init(managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
		self.managedContext = managedContext
		entity = NSEntityDescription.entity(forEntityName: "CatchEntity", in: managedContext)!
	}

	func getAll() -> [NSManagedObject] {
		return fetch(predicate: nil)
	}

	func getAll(number: Int) -> [NSManagedObject] {
		return fetch(predicate: NSPredicate(format: "number == %d", number))
	}

	func insert(catchToInsert: Catch) {
		let catchEntity = NSManagedObject(entity: entity, insertInto: managedContext)
		write(caught: catchToInsert, to: catchEntity)
		catchToInsert.catchEntity = catchEntity
	}

	func update(catchToUpdate: Catch) {
		if let catchEntity = catchToUpdate.catchEntity {
			write(caught: catchToUpdate, to: catchEntity)
		}
	}

	fileprivate func write(caught: Catch, to catchEntity: NSManagedObject) {
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

	func delete(catchToDelete: Catch) {
		if let catchEntity = catchToDelete.catchEntity {
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

	fileprivate func fetch(predicate: NSPredicate?) -> [NSManagedObject] {
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
