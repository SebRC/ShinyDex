import Foundation

struct JourneyEntry: Equatable {
    let id: UUID
    var number: Int
    var catchId: UUID?
    var phaseCatchIds: [UUID]

    init(id: UUID = UUID(), number: Int, catchId: UUID? = nil, phaseCatchIds: [UUID] = []) {
        self.id = id
        self.number = number
        self.catchId = catchId
        self.phaseCatchIds = phaseCatchIds
    }
}

class Journey {
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

    init(id: UUID, name: String, createdDate: Date, priority: Int, entries: [JourneyEntry]) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.priority = priority
        self.entries = entries
    }

    func findLinkedCatch(for entry: JourneyEntry, in catchesById: [UUID: Catch]) -> Catch? {
        guard let catchId = entry.catchId, let caught = catchesById[catchId], !caught.isFailed else { return nil }
        return caught
    }

    func countCaught(in catchesById: [UUID: Catch]) -> Int {
        return entries.filter { findLinkedCatch(for: $0, in: catchesById) != nil }.count
    }

    func getPhases(for entry: JourneyEntry, in catchesById: [UUID: Catch]) -> [Catch] {
        return entry.phaseCatchIds.compactMap { catchesById[$0] }
    }

    func makeTimeline(in catchesById: [UUID: Catch]) -> [(entry: JourneyEntry, caught: Catch, isPhase: Bool)] {
        let steps = entries.flatMap { entry -> [(entry: JourneyEntry, caught: Catch, isPhase: Bool)] in
            let phaseSteps = getPhases(for: entry, in: catchesById).map { (entry: entry, caught: $0, isPhase: true) }
            let targetStep = findLinkedCatch(for: entry, in: catchesById).map { [(entry: entry, caught: $0, isPhase: false)] } ?? []
            return phaseSteps + targetStep
        }
        let sorted = steps.enumerated().sorted { first, second in
            switch (first.element.caught.caughtDate, second.element.caught.caughtDate) {
            case let (firstDate?, secondDate?) where firstDate != secondDate: return firstDate < secondDate
            case (.some, nil): return true
            case (nil, .some): return false
            default: return first.offset < second.offset
            }
        }
        return sorted.map { $0.element }
    }

    func isLinked(_ caught: Catch) -> Bool {
        return entries.contains { $0.catchId == caught.id || $0.phaseCatchIds.contains(caught.id) }
    }

    @discardableResult
    func addPhase(_ catchId: UUID, toEntry entryId: UUID) -> Bool {
        guard let index = entries.firstIndex(where: { $0.id == entryId }),
              !entries.contains(where: { $0.catchId == catchId || $0.phaseCatchIds.contains(catchId) }) else { return false }
        entries[index].phaseCatchIds.append(catchId)
        return true
    }

    func removePhase(_ catchId: UUID, fromEntry entryId: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        entries[index].phaseCatchIds.removeAll { $0 == catchId }
    }
}
