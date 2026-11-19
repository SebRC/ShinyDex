import Foundation

struct DeleteJourneyCommand {
    let journeyId: JourneyID
}

final class DeleteJourneyHandler {
    private let journeyRepository: JourneyRepository

    init(journeyRepository: JourneyRepository) {
        self.journeyRepository = journeyRepository
    }

    func handle(_ command: DeleteJourneyCommand) {
        guard let journey = journeyRepository.getAll().first(where: { $0.id == command.journeyId.rawValue }) else { return }
        journeyRepository.delete(journey)
    }
}
