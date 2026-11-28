import Foundation

struct CreateTeamCommand {
    let name: String
}

final class CreateTeamHandler {
    private let teamRepository: TeamRepository
    private let makeCurrentDate: () -> Date

    init(teamRepository: TeamRepository, makeCurrentDate: @escaping () -> Date = Date.init) {
        self.teamRepository = teamRepository
        self.makeCurrentDate = makeCurrentDate
    }

    @discardableResult
    func handle(_ command: CreateTeamCommand) -> TeamID {
        let team = Team(name: command.name, createdDate: makeCurrentDate())
        teamRepository.save(team)
        return TeamID(rawValue: team.id)
    }
}
