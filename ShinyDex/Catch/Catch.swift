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
	var isFailed: Bool
	var evs: EffortValues
	var evolvedFrom: Int?

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
		self.isFailed = catchEntity.value(forKey: "isFailed") as? Bool ?? false
		self.evs = EffortValues(encoded: catchEntity.value(forKey: "evs") as? String)
		let evolvedFrom = catchEntity.value(forKey: "evolvedFrom") as? Int ?? -1
		self.evolvedFrom = evolvedFrom >= 0 ? evolvedFrom : nil
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

	func revertToSaved() {
		guard let catchEntity = catchEntity else {
			return
		}
		let saved = Catch(catchEntity: catchEntity)
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

	var formattedCaughtDate: String? {
		return caughtDate.map { Catch.dateFormatter.string(from: $0) }
	}

	var caughtDateText: String {
		return formattedCaughtDate ?? "Logged before catch history"
	}
}
