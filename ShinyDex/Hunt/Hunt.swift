import Foundation
import CoreData

class Hunt {
	var huntEntity: NSManagedObject?
	var name: String
	var indexes: [Int]
	var pokemon: [Pokemon]
	var totalEncounters: Int
	var priority: Int
	var isCollapsed: Bool

	init(huntEntity: NSManagedObject) {
		self.huntEntity = huntEntity
		self.name = huntEntity.value(forKey: "name") as! String
		self.indexes = huntEntity.value(forKey: "indexes") as! [Int]
		self.priority = huntEntity.value(forKey: "priority") as! Int
		self.isCollapsed = huntEntity.value(forKey: "isCollapsed") as! Bool
		self.pokemon = [Pokemon]()
		self.totalEncounters = 0
	}

	init(name: String, pokemon: [Pokemon], priority: Int) {
		self.name = name
		self.indexes = [Int]()
		self.priority = priority
		self.pokemon = pokemon
		self.totalEncounters = 0
		self.isCollapsed = false
	}
}
