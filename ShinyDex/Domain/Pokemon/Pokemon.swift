import Foundation

class Pokemon: NSObject {
	var name: String
	var number: Int
	var encounters: Int
	var chain = 0
	var caughtDescription: String
	var caughtBall: String
	var isBeingHunted: Bool
	var generation: Int
	var isShinyCharmActive: Bool
	var shinyOdds: Int
	var huntMethod: HuntMethod
	var increment: Int
    var game: Games

	init(name: String, number: Int, encounters: Int, caughtDescription: String, caughtBall: String, isBeingHunted: Bool, generation: Int, isShinyCharmActive: Bool, shinyOdds: Int, huntMethod: HuntMethod, increment: Int, game: Games) {
		self.name = name
		self.number = number
		self.encounters = encounters
		self.caughtDescription = caughtDescription
		self.caughtBall = caughtBall
		self.isBeingHunted = isBeingHunted
		self.generation = generation
		self.isShinyCharmActive = isShinyCharmActive
		self.shinyOdds = shinyOdds
		self.huntMethod = huntMethod
		self.increment = increment
		self.game = game
	}

	convenience init(newlyAddedNamed name: String, number: Int) {
		self.init(name: name, number: number, encounters: 0, caughtDescription: "Not Caught", caughtBall: "none", isBeingHunted: false, generation: 2, isShinyCharmActive: false, shinyOdds: 8192, huntMethod: .Encounters, increment: 1, game: .Red)
	}

	override init() {
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
