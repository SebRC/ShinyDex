import Foundation

struct JourneyMember: Equatable {
    let number: Int
    let name: String
    let isCaught: Bool
}

struct JourneySummary: Equatable {
    let id: JourneyID
    let name: String
    let caughtCount: Int
    let members: [JourneyMember]

    var isComplete: Bool {
        return !members.isEmpty && caughtCount == members.count
    }
}

struct JourneyEntryDetails: Equatable {
    let id: JourneyEntryID
    let number: Int
    let pokemonName: String?
    let linkedCatch: CatchSummary?
    let linkableCatchCount: Int
}

struct JourneyDetails: Equatable {
    let id: JourneyID
    let name: String
    let entries: [JourneyEntryDetails]
    let timeline: [CatchSummary]

    var caughtCount: Int {
        return entries.filter { $0.linkedCatch != nil }.count
    }
}

// Shared by the journey queries: which catches an entry links to, and which it could link to.
struct JourneyCatchLinks {
    let caught: [Catch]
    let catchesById: [UUID: Catch]
    let evolutions: Evolutions

    init(catches: [Catch], evolutions: Evolutions) {
        caught = catches.filter { !$0.isFailed }
        catchesById = Dictionary(caught.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.evolutions = evolutions
    }

    func linkable(for entry: JourneyEntry, in journey: Journey) -> [Catch] {
        let line = Set(evolutions.line(of: entry.number)).union([entry.number])
        return caught
            .filter { line.contains($0.number) && (!journey.isLinked($0) || $0.id == entry.catchId) }
            .sorted { ($0.number == entry.number ? 0 : 1, $0.caughtDate ?? .distantPast) < ($1.number == entry.number ? 0 : 1, $1.caughtDate ?? .distantPast) }
    }
}
