import Foundation

class MoveService {
	fileprivate let moveRepository: MoveRepository = AppContainer.shared.moveRepository
    
	func getMoves() -> [Move] {
		if let url = Bundle.main.url(forResource: "moves", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let jsonData = try decoder.decode([Move].self, from: data)
                return jsonData.sorted{ $0.identifier < $1.identifier}
			
			} catch {
				print("error:\(error)")
			}
		}
		return [Move]()
	}

	func getAll() -> [ActiveMove] {
		return moveRepository.getActiveMoves()?.moves ?? [ActiveMove]()
	}

	func getIsPressureActive() -> Bool {
		return moveRepository.getActiveMoves()?.pressureActive ?? false
	}

	func save(activeMoves: [ActiveMove], pressureActive: Bool) {
		moveRepository.save(ActiveMoves(moves: activeMoves, pressureActive: pressureActive))
	}

	func populateDatabase() {
		if let url = Bundle.main.url(forResource: "initialActiveMoves", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let moves = try JSONDecoder().decode([ActiveMove].self, from: data)
				moveRepository.insert(ActiveMoves(moves: moves, pressureActive: false))
			} catch {
				print("error:\(error)")
			}
		}
	}

	func deleteAll() {
		moveRepository.deleteAll()
	}
}
