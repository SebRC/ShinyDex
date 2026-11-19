import Foundation

class Catch {
	var id: UUID
	var number: Int
	var caughtBall: String
	var game: Games
	var huntMethod: HuntMethod
	var encounters: Int
	var isShinyCharmActive: Bool
	var caughtDate: Date?
	var isFailed: Bool
	var evs: EffortValues
	var evolvedFrom: Int?

	init(id: UUID, number: Int, caughtBall: String, game: Games, huntMethod: HuntMethod, encounters: Int, isShinyCharmActive: Bool, caughtDate: Date?, isFailed: Bool, evs: EffortValues, evolvedFrom: Int?) {
		self.id = id
		self.number = number
		self.caughtBall = caughtBall
		self.game = game
		self.huntMethod = huntMethod
		self.encounters = encounters
		self.isShinyCharmActive = isShinyCharmActive
		self.caughtDate = caughtDate
		self.isFailed = isFailed
		self.evs = evs
		self.evolvedFrom = evolvedFrom
	}

	init(number: Int, caughtBall: String, game: Games, huntMethod: HuntMethod, encounters: Int, isShinyCharmActive: Bool, caughtDate: Date?, isFailed: Bool = false) {
		self.id = UUID()
		self.number = number
		self.caughtBall = caughtBall
		self.game = game
		self.huntMethod = huntMethod
		self.encounters = encounters
		self.isShinyCharmActive = isShinyCharmActive
		self.caughtDate = caughtDate
		self.isFailed = isFailed
		self.evs = EffortValues()
		self.evolvedFrom = nil
	}

	func restore(from saved: Catch) {
		caughtBall = saved.caughtBall
		game = saved.game
		huntMethod = saved.huntMethod
		encounters = saved.encounters
		isShinyCharmActive = saved.isShinyCharmActive
		caughtDate = saved.caughtDate
		isFailed = saved.isFailed
		evs = saved.evs
		evolvedFrom = saved.evolvedFrom
		number = saved.number
	}

	convenience init(pokemon: Pokemon, caughtBall: String, caughtDate: Date?, isFailed: Bool = false) {
		self.init(number: pokemon.number,
				  caughtBall: caughtBall,
				  game: pokemon.game,
				  huntMethod: pokemon.huntMethod,
				  encounters: pokemon.encounters,
				  isShinyCharmActive: pokemon.isShinyCharmActive,
				  caughtDate: caughtDate,
				  isFailed: isFailed)
	}
}
