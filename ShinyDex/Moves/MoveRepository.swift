//
//  MoveRepository.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 29/07/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class MoveRepository {
	fileprivate var appDelegate: AppDelegate
	fileprivate var managedContext: NSManagedObjectContext
	fileprivate var entity: NSEntityDescription

	init() {
		appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
		managedContext = appDelegate.persistentContainer.viewContext
		entity = NSEntityDescription.entity(forEntityName: "ActiveMovesEntity", in: managedContext)!
	}

	func getAll() -> [NSManagedObject] {
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ActiveMovesEntity")
		do {
			let activeMovesEntities = try managedContext.fetch(fetchRequest)
			return activeMovesEntities
		}
		catch let error as NSError {
			print("Could not fetch ActiveMovesEntity table. \(error.localizedDescription)")
		}
		return []
	}

	func save(activeMoves: ActiveMoves) {
		activeMoves.activeMovesEntity.setValue(activeMoves.json, forKey: "json")
        activeMoves.activeMovesEntity.setValue(activeMoves.pressureActive, forKey: "pressureActive")
		do {
			try managedContext.save()
		}
		catch let error as NSError {
			print("Could not save \(activeMoves.json). \(error.localizedDescription)")
		}
	}

	func save(json: String) {
		let activeMovesEntity = NSManagedObject(entity: entity, insertInto: managedContext)
		activeMovesEntity.setValue(json, forKey: "json")
        activeMovesEntity.setValue(false, forKey: "pressureActive")
		let activeMoves = ActiveMoves(moveEntity: activeMovesEntity)
		activeMoves.json = json
		save(activeMoves: activeMoves)
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
}
