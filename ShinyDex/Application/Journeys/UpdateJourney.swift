import Foundation

struct UpdateJourneyCommand {
    enum Change: Equatable {
        case rename(String)
        case addPokemon([Int])
        case removeEntry(JourneyEntryID)
        case moveEntry(from: Int, to: Int)
        case link(entry: JourneyEntryID, catchId: CatchID?)
    }

    let journeyId: JourneyID
    let change: Change
}

final class UpdateJourneyHandler {
    private let journeyRepository: JourneyRepository

    init(journeyRepository: JourneyRepository) {
        self.journeyRepository = journeyRepository
    }

    func handle(_ command: UpdateJourneyCommand) {
        guard let journey = journeyRepository.getAll().first(where: { $0.id == command.journeyId.rawValue }) else { return }
        switch command.change {
        case .rename(let name):
            journey.name = name
        case .addPokemon(let numbers):
            journey.entries.append(contentsOf: numbers.map { JourneyEntry(number: $0) })
        case .removeEntry(let entryId):
            journey.entries.removeAll { $0.id == entryId.rawValue }
        case .moveEntry(let source, let destination):
            guard journey.entries.indices.contains(source), journey.entries.indices.contains(destination) else { return }
            journey.entries.insert(journey.entries.remove(at: source), at: destination)
        case .link(let entryId, let catchId):
            guard let index = journey.entries.firstIndex(where: { $0.id == entryId.rawValue }) else { return }
            journey.entries[index].catchId = catchId?.rawValue
        }
        journeyRepository.save(journey)
    }
}
