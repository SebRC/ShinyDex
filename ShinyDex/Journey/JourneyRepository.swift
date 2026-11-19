import Foundation
import UIKit
import CoreData

class JourneyRepository {
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription

	init(managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
		self.managedContext = managedContext
		entity = NSEntityDescription.entity(forEntityName: "JourneyEntity", in: managedContext)!
	}

	func getAll() -> [NSManagedObject] {
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JourneyEntity")
		do {
			return try managedContext.fetch(fetchRequest)
		}
		catch let error as NSError {
			print("Could not fetch JourneyEntity table. \(error.localizedDescription)")
		}
		return []
	}

	@discardableResult
	func save(journey: Journey) -> Bool {
		let journeyEntity = journey.journeyEntity ?? NSManagedObject(entity: entity, insertInto: managedContext)
		journeyEntity.setValue(journey.id, forKey: "id")
		journeyEntity.setValue(journey.name, forKey: "name")
		journeyEntity.setValue(journey.createdDate, forKey: "createdDate")
		journeyEntity.setValue(journey.priority, forKey: "priority")
		journeyEntity.setValue(journey.encodedEntries, forKey: "entries")
		journey.journeyEntity = journeyEntity
		return save()
	}

	func delete(journey: Journey) {
		guard let journeyEntity = journey.journeyEntity else { return }
		managedContext.delete(journeyEntity)
		save()
	}

	@discardableResult
	fileprivate func save() -> Bool {
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
