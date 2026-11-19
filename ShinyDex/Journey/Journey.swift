import Foundation
import CoreData

struct JourneyEntry: Codable, Equatable {
	let id: UUID
	var number: Int
	var catchId: UUID?

	init(number: Int, catchId: UUID? = nil) {
		self.id = UUID()
		self.number = number
		self.catchId = catchId
	}
}

class Journey {
	var journeyEntity: NSManagedObject?
	let id: UUID
	var name: String
	let createdDate: Date
	var priority: Int
	var entries: [JourneyEntry]

	init(name: String, priority: Int, numbers: [Int]) {
		id = UUID()
		self.name = name
		createdDate = Date()
		self.priority = priority
		entries = numbers.map { JourneyEntry(number: $0) }
	}

	init(journeyEntity: NSManagedObject) {
		self.journeyEntity = journeyEntity
		id = journeyEntity.value(forKey: "id") as? UUID ?? UUID()
		name = journeyEntity.value(forKey: "name") as? String ?? "Journey"
		createdDate = journeyEntity.value(forKey: "createdDate") as? Date ?? Date()
		priority = journeyEntity.value(forKey: "priority") as? Int ?? 0
		let json = (journeyEntity.value(forKey: "entries") as? String)?.data(using: .utf8) ?? Data()
		entries = (try? JSONDecoder().decode([JourneyEntry].self, from: json)) ?? []
	}

	var encodedEntries: String {
		let data = (try? JSONEncoder().encode(entries)) ?? Data()
		return String(data: data, encoding: .utf8) ?? "[]"
	}

	func linkedCatch(for entry: JourneyEntry, in catchesById: [UUID: Catch]) -> Catch? {
		guard let catchId = entry.catchId, let caught = catchesById[catchId], !caught.isFailed else { return nil }
		return caught
	}

	func caughtCount(in catchesById: [UUID: Catch]) -> Int {
		return entries.filter { linkedCatch(for: $0, in: catchesById) != nil }.count
	}

	func timeline(in catchesById: [UUID: Catch]) -> [(entry: JourneyEntry, caught: Catch)] {
		let linked = entries.enumerated().compactMap { position, entry in
			linkedCatch(for: entry, in: catchesById).map { (position: position, entry: entry, caught: $0) }
		}
		let sorted = linked.sorted { first, second in
			switch (first.caught.caughtDate, second.caught.caughtDate) {
			case let (firstDate?, secondDate?) where firstDate != secondDate: return firstDate < secondDate
			case (.some, nil): return true
			case (nil, .some): return false
			default: return first.position < second.position
			}
		}
		return sorted.map { (entry: $0.entry, caught: $0.caught) }
	}

	func isLinked(_ caught: Catch) -> Bool {
		return entries.contains { $0.catchId == caught.id }
	}
}
