import Foundation

struct DeleteTeamCommand {
    let teamId: TeamID
}

final class DeleteTeamHandler {
    private let teamRepository: TeamRepository

    init(teamRepository: TeamRepository) {
        self.teamRepository = teamRepository
    }

    func handle(_ command: DeleteTeamCommand) {
        teamRepository.delete(id: command.teamId.rawValue)
    }
}
