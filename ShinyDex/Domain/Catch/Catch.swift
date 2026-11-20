import Foundation

class Catch {
	static let maximumNicknameLength = 12

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
	var nickname: String? {
		didSet { nickname = Catch.normalizeNickname(nickname) }
	}
	var gender: Gender?
	var nature: Nature?
	var ivs: IndividualValues

	init(id: UUID, number: Int, caughtBall: String, game: Games, huntMethod: HuntMethod, encounters: Int, isShinyCharmActive: Bool, caughtDate: Date?, isFailed: Bool, evs: EffortValues, evolvedFrom: Int?,
		 nickname: String? = nil, gender: Gender? = nil, nature: Nature? = nil, ivs: IndividualValues = IndividualValues()) {
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
		self.nickname = Catch.normalizeNickname(nickname)
		self.gender = gender
		self.nature = nature
		self.ivs = ivs
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
		self.ivs = IndividualValues()
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
		nickname = saved.nickname
		gender = saved.gender
		nature = saved.nature
		ivs = saved.ivs
	}

	static func normalizeNickname(_ nickname: String?) -> String? {
		guard let trimmed = nickname?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
		return String(trimmed.prefix(maximumNicknameLength))
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
