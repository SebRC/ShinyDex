import Foundation
import UIKit
import CoreData

class Pokemon: NSObject {
	var pokemonEntity: NSManagedObject
	var name: String
	var number: Int
	var encounters: Int
	var caughtDescription: String
	var caughtBall: String
	var isBeingHunted: Bool
	var generation: Int
	var isShinyCharmActive: Bool
	var shinyOdds: Int
	var huntMethod: HuntMethod
	var increment: Int
    var game: Games

	init(pokemonEntity: NSManagedObject) {
		self.pokemonEntity = pokemonEntity
		self.name = pokemonEntity.value(forKey: "name") as! String
		self.number = pokemonEntity.value(forKey: "number") as! Int
		self.caughtDescription = pokemonEntity.value(forKey: "caughtDescription") as! String
		self.encounters = pokemonEntity.value(forKey: "encounters") as! Int
		self.isBeingHunted = pokemonEntity.value(forKey: "isBeingHunted") as? Bool ?? false
		self.caughtBall = pokemonEntity.value(forKey: "caughtBall") as! String
		self.generation = pokemonEntity.value(forKey: "generation") as! Int
		self.isShinyCharmActive = pokemonEntity.value(forKey: "isShinyCharmActive") as! Bool
		self.shinyOdds = pokemonEntity.value(forKey: "shinyOdds") as! Int
		self.huntMethod = HuntMethod(rawValue: pokemonEntity.value(forKey: "huntMethod") as! String)!
		self.increment = pokemonEntity.value(forKey: "increment") as! Int
        self.game = Games(rawValue: pokemonEntity.value(forKey: "game") as? String ?? Games.Red.rawValue) ?? Games.Red
	}

	override init() {
		self.pokemonEntity = NSManagedObject()
		self.name = "Placeholder"
		self.number = -1
		self.caughtDescription = "Placeholder"
		self.encounters = -1
		self.isBeingHunted = false
		self.caughtBall = "Placeholder"
		self.generation = 1
		self.isShinyCharmActive = false
		self.shinyOdds = 8192
		self.huntMethod = HuntMethod.Encounters
		self.increment = 1
        self.game = Games.Red
	}
}
