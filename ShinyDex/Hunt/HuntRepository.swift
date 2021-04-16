//
//  HuntRepository.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/10/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HuntRepository {
	fileprivate var appDelegate: AppDelegate
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription

	init() {
		appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
		managedContext = appDelegate.persistentContainer.viewContext
		entity = NSEntityDescription.entity(forEntityName: "HuntEntity", in: managedContext)!
	}

	func getAll() -> [NSManagedObject] {
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HuntEntity")
		do {
			let huntEntities = try managedContext.fetch(fetchRequest)
			return huntEntities
		}
		catch let error as NSError {
			print("Could not fetch HuntEntity table. \(error.localizedDescription)")
		}
		return []
	}

	func save(hunt: Hunt) {
		if (hunt.huntEntity == nil) {
			hunt.huntEntity = NSManagedObject(entity: entity, insertInto: managedContext)
		}
		hunt.huntEntity?.setValue(hunt.name, forKey: "name")
		hunt.huntEntity?.setValue(hunt.indexes, forKey: "indexes")
		hunt.huntEntity?.setValue(hunt.priority, forKey: "priority")
		hunt.huntEntity?.setValue(hunt.isCollapsed, forKey: "isCollapsed")

		save()
	}

	func clear(){
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "HuntEntity")
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		do {
			try managedContext.execute(deleteRequest)
		}
		catch let error as NSError {
			print("Could not clear table. \(error.localizedDescription)")
		}
		save()
	}

	func delete(hunt: Hunt) {
		managedContext.delete(hunt.huntEntity!)
		save()
	}

	fileprivate func save() {
		do {
			try managedContext.save()
		}
		catch let error as NSError {
			print("Could not save. \(error.localizedDescription)")
		}
	}
}
