import Foundation
import CoreData

class Catch {
	var catchEntity: NSManagedObject?
	var id: UUID
	var number: Int
	var caughtBall: String
	var game: Games
	var huntMethod: HuntMethod
	var encounters: Int
	var isShinyCharmActive: Bool
	var caughtDate: Date?

	init(catchEntity: NSManagedObject) {
		self.catchEntity = catchEntity
		self.id = catchEntity.value(forKey: "id") as? UUID ?? UUID()
		self.number = catchEntity.value(forKey: "number") as? Int ?? 0
		self.caughtBall = catchEntity.value(forKey: "caughtBall") as? String ?? CatchRules.noBall
		self.game = Games(rawValue: catchEntity.value(forKey: "game") as? String ?? "") ?? Games.Red
		self.huntMethod = HuntMethod(rawValue: catchEntity.value(forKey: "huntMethod") as? String ?? "") ?? HuntMethod.Encounters
		self.encounters = catchEntity.value(forKey: "encounters") as? Int ?? 0
		self.isShinyCharmActive = catchEntity.value(forKey: "isShinyCharmActive") as? Bool ?? false
		self.caughtDate = catchEntity.value(forKey: "caughtDate") as? Date
	}

	init(number: Int, caughtBall: String, game: Games, huntMethod: HuntMethod, encounters: Int, isShinyCharmActive: Bool, caughtDate: Date?) {
		self.id = UUID()
		self.number = number
		self.caughtBall = caughtBall
		self.game = game
		self.huntMethod = huntMethod
		self.encounters = encounters
		self.isShinyCharmActive = isShinyCharmActive
		self.caughtDate = caughtDate
	}

	convenience init(pokemon: Pokemon, caughtBall: String, caughtDate: Date?) {
		self.init(number: pokemon.number,
				  caughtBall: caughtBall,
				  game: pokemon.game,
				  huntMethod: pokemon.huntMethod,
				  encounters: pokemon.encounters,
				  isShinyCharmActive: pokemon.isShinyCharmActive,
				  caughtDate: caughtDate)
	}
}

extension Catch {
	fileprivate static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()

	var ballName: String {
		return "\(caughtBall.capitalizingFirstLetter()) Ball"
	}

	var caughtDateText: String {
		return caughtDate.map { Catch.dateFormatter.string(from: $0) } ?? "Logged before catch history"
	}
}
