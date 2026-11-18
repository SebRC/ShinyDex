import Foundation
import UIKit
import CoreData

class CatchRepository {
	fileprivate var appDelegate: AppDelegate
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription

	init() {
		appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
		managedContext = appDelegate.persistentContainer.viewContext
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
		catchEntity.setValue(catchToInsert.id, forKey: "id")
		catchEntity.setValue(catchToInsert.number, forKey: "number")
		catchEntity.setValue(catchToInsert.caughtBall, forKey: "caughtBall")
		catchEntity.setValue(catchToInsert.game.rawValue, forKey: "game")
		catchEntity.setValue(catchToInsert.huntMethod.rawValue, forKey: "huntMethod")
		catchEntity.setValue(catchToInsert.encounters, forKey: "encounters")
		catchEntity.setValue(catchToInsert.isShinyCharmActive, forKey: "isShinyCharmActive")
		catchEntity.setValue(catchToInsert.caughtDate, forKey: "caughtDate")
		catchToInsert.catchEntity = catchEntity
	}

	func delete(catchToDelete: Catch) {
		if let catchEntity = catchToDelete.catchEntity {
			managedContext.delete(catchEntity)
		}
	}

	// On failure the unsaved changes are rolled back, so they can't be persisted later by an unrelated save.
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
