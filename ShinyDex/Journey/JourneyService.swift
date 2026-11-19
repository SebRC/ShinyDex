import Foundation

class JourneyService {
	fileprivate let journeyRepository = JourneyRepository()
	fileprivate let catchService = CatchService()

	func getAll() -> [Journey] {
		return journeyRepository.getAll().map { Journey(journeyEntity: $0) }.sorted { $0.priority < $1.priority }
	}

	func catchesById() -> [UUID: Catch] {
		return Dictionary(catchService.getAll().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
	}

	func createJourney(named name: String, numbers: [Int]) -> Journey {
		let priority = (getAll().map { $0.priority }.max() ?? -1) + 1
		let journey = Journey(name: name, priority: priority, numbers: numbers)
		journeyRepository.save(journey: journey)
		return journey
	}

	func rename(_ journey: Journey, to name: String) {
		journey.name = name
		journeyRepository.save(journey: journey)
	}

	func add(numbers: [Int], to journey: Journey) {
		journey.entries.append(contentsOf: numbers.map { JourneyEntry(number: $0) })
		journeyRepository.save(journey: journey)
	}

	func removeEntry(_ entryId: UUID, from journey: Journey) {
		journey.entries.removeAll { $0.id == entryId }
		journeyRepository.save(journey: journey)
	}

	func moveEntry(from source: Int, to destination: Int, in journey: Journey) {
		guard journey.entries.indices.contains(source), journey.entries.indices.contains(destination) else { return }
		journey.entries.insert(journey.entries.remove(at: source), at: destination)
		journeyRepository.save(journey: journey)
	}

	func link(_ caught: Catch?, toEntry entryId: UUID, in journey: Journey) {
		guard let index = journey.entries.firstIndex(where: { $0.id == entryId }) else { return }
		journey.entries[index].catchId = caught?.id
		journeyRepository.save(journey: journey)
	}

	func delete(_ journey: Journey) {
		journeyRepository.delete(journey: journey)
	}

	func linkableCatches(for entry: JourneyEntry, in journey: Journey) -> [Catch] {
		let line = Set(Evolutions.shared.line(of: entry.number)).union([entry.number])
		return catchService.getAll()
			.filter { line.contains($0.number) && (!journey.isLinked($0) || $0.id == entry.catchId) }
			.sorted { ($0.number == entry.number ? 0 : 1, $0.caughtDate ?? .distantPast) < ($1.number == entry.number ? 0 : 1, $1.caughtDate ?? .distantPast) }
	}
}
