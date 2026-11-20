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
    let phases: [CatchSummary]
}

struct JourneyTimelineStep: Equatable {
    let caught: CatchSummary
    let isPhase: Bool
    let entryPokemonName: String?
}

struct JourneyDetails: Equatable {
    let id: JourneyID
    let name: String
    let entries: [JourneyEntryDetails]
    let timeline: [JourneyTimelineStep]

    var caughtCount: Int {
        return entries.filter { $0.linkedCatch != nil }.count
    }

    var phaseCount: Int {
        return entries.reduce(0) { $0 + $1.phases.count }
    }
}

enum JourneyCatchRole {
    case target, phase
}

struct JourneyCatchLinks {
    let catches: [Catch]
    let catchesById: [UUID: Catch]
    let evolutions: Evolutions

    init(catches: [Catch], evolutions: Evolutions) {
        self.catches = catches
        catchesById = Dictionary(catches.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.evolutions = evolutions
    }

    func findLinkableCatches(for entry: JourneyEntry, in journey: Journey, as role: JourneyCatchRole = .target) -> [Catch] {
        let line = Set(evolutions.getLine(of: entry.number)).union([entry.number])
        switch role {
        case .target:
            return catches
                .filter { !$0.isFailed && line.contains($0.number) && (!journey.isLinked($0) || $0.id == entry.catchId) }
                .sorted { ($0.number == entry.number ? 0 : 1, $0.caughtDate ?? .distantPast) < ($1.number == entry.number ? 0 : 1, $1.caughtDate ?? .distantPast) }
        case .phase:
            return catches
                .filter { !line.contains($0.number) && !journey.isLinked($0) }
                .sorted { ($0.caughtDate ?? .distantPast) > ($1.caughtDate ?? .distantPast) }
        }
    }
}
