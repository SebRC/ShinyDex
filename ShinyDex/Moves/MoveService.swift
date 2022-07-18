import Foundation

class MoveService {
	var moveRepository = MoveRepository()
    
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
		do {
			let activeMovesEntity = moveRepository.getAll().first
			let json = activeMovesEntity!.value(forKey: "json") as! String
			let decoder = JSONDecoder()
			let data = json.data(using: String.Encoding.utf8)!
			let activeMoves = try decoder.decode([ActiveMove].self, from: data)
			return activeMoves
		} catch {
			print("error:\(error)")
		}
		return [ActiveMove]()
	}
    
    func getIsPressureActive() -> Bool {
        let activeMovesEntity = moveRepository.getAll().first
        let pressureActive = activeMovesEntity!.value(forKey: "pressureActive") as! Bool
        return pressureActive
    }

    func save(activeMoves: [ActiveMove], pressureActive: Bool) {
		do {
			let encoder = JSONEncoder()
			let json = try encoder.encode(activeMoves)
			let activeMovesEntity = moveRepository.getAll().first!
			let activeMoves = ActiveMoves(moveEntity: activeMovesEntity)
			activeMoves.json = String(data: json, encoding: String.Encoding.utf8)!
            activeMoves.pressureActive = pressureActive
			moveRepository.save(activeMoves: activeMoves)

		} catch {
			print("error:\(error)")
		}
	}

	func populateDatabase() {
		if let url = Bundle.main.url(forResource: "initialActiveMoves", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let json = String(data: data, encoding: String.Encoding.utf8)!
				moveRepository.save(json: json)

			} catch {
				print("error:\(error)")
			}
		}
	}

	func deleteAll() {
		moveRepository.deleteAll()
	}
}
