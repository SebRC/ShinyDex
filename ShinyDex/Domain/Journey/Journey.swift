import Foundation

struct JourneyTimelineItem {
    let entry: JourneyEntry
    let caught: Catch
    let isPhase: Bool
    var alsoPhaseFor: JourneyEntry? = nil
}

struct JourneyEntry: Equatable {
    let id: UUID
    var number: Int
    var catchId: UUID?
    var phaseCatchIds: [UUID]
    var formId: String?

    init(id: UUID = UUID(), number: Int, catchId: UUID? = nil, phaseCatchIds: [UUID] = [], formId: String? = nil) {
        self.id = id
        self.number = number
        self.catchId = catchId
        self.phaseCatchIds = phaseCatchIds
        self.formId = formId
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
        guard let catchId = entry.catchId, let caught = catchesById[catchId], !caught.isFailed, caught.matchesForm(entry.formId) else { return nil }
        return caught
    }

    func countCaught(in catchesById: [UUID: Catch]) -> Int {
        return entries.filter { findLinkedCatch(for: $0, in: catchesById) != nil }.count
    }

    func getPhases(for entry: JourneyEntry, in catchesById: [UUID: Catch]) -> [Catch] {
        return CatchRules.sortedByKnownDateFirst(entry.phaseCatchIds.compactMap { catchesById[$0] })
    }

    func makeTimeline(in catchesById: [UUID: Catch]) -> [JourneyTimelineItem] {
        let steps = entries.flatMap { entry -> [JourneyTimelineItem] in
            let phaseSteps = getPhases(for: entry, in: catchesById)
                .filter { !isTarget($0.id) }
                .map { JourneyTimelineItem(entry: entry, caught: $0, isPhase: true) }
            let targetStep = findLinkedCatch(for: entry, in: catchesById).map { caught in
                [JourneyTimelineItem(entry: entry, caught: caught, isPhase: false, alsoPhaseFor: entries.first { $0.phaseCatchIds.contains(caught.id) })]
            } ?? []
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

    func findCatches(in catchesById: [UUID: Catch]) -> [Catch] {
        var seen = Set<UUID>()
        return entries.flatMap { entry in getPhases(for: entry, in: catchesById) + (findLinkedCatch(for: entry, in: catchesById).map { [$0] } ?? []) }
            .filter { seen.insert($0.id).inserted }
    }

    func makeTally(in catchesById: [UUID: Catch]) -> JourneyTally {
        return JourneyTally(catches: findCatches(in: catchesById))
    }

    func isTarget(_ catchId: UUID) -> Bool {
        return entries.contains { $0.catchId == catchId }
    }

    func isPhase(_ catchId: UUID) -> Bool {
        return entries.contains { $0.phaseCatchIds.contains(catchId) }
    }

    func canLink(_ catchId: UUID, to entryId: UUID) -> Bool {
        guard let entry = entries.first(where: { $0.id == entryId }) else { return false }
        let isOtherEntrysTarget = entries.contains { $0.id != entryId && $0.catchId == catchId }
        return !isOtherEntrysTarget && !entry.phaseCatchIds.contains(catchId)
    }

    func canAddPhase(_ catchId: UUID, to entryId: UUID) -> Bool {
        guard let entry = entries.first(where: { $0.id == entryId }) else { return false }
        return entry.catchId != catchId && !isPhase(catchId)
    }

    @discardableResult
    func link(_ catchId: UUID?, toEntry entryId: UUID) -> Bool {
        guard let index = entries.firstIndex(where: { $0.id == entryId }), catchId.map({ canLink($0, to: entryId) }) ?? true else { return false }
        entries[index].catchId = catchId
        return true
    }

    @discardableResult
    func addPhase(_ catchId: UUID, toEntry entryId: UUID) -> Bool {
        guard canAddPhase(catchId, to: entryId), let index = entries.firstIndex(where: { $0.id == entryId }) else { return false }
        entries[index].phaseCatchIds.append(catchId)
        return true
    }

    func setForm(_ formId: String?, ofEntry entryId: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        guard entries[index].formId != formId else { return }
        entries[index].formId = formId
        entries[index].catchId = nil
    }

    func removePhase(_ catchId: UUID, fromEntry entryId: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        entries[index].phaseCatchIds.removeAll { $0 == catchId }
    }
}
