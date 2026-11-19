import Foundation

struct CreateJourneyCommand {
    let name: String
    let pokemonNumbers: [Int]
}

final class CreateJourneyHandler {
    private let journeyRepository: JourneyRepository

    init(journeyRepository: JourneyRepository) {
        self.journeyRepository = journeyRepository
    }

    @discardableResult
    func handle(_ command: CreateJourneyCommand) -> JourneyID {
        let priority = (journeyRepository.getAll().map { $0.priority }.max() ?? -1) + 1
        let journey = Journey(name: command.name, priority: priority, numbers: command.pokemonNumbers)
        journeyRepository.save(journey)
        return JourneyID(rawValue: journey.id)
    }
}
