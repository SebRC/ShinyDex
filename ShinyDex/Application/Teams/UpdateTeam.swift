import Foundation

struct UpdateTeamCommand {
    enum Change {
        case rename(String)
        case add(CatchID)
        case remove(CatchID)
    }

    let teamId: TeamID
    let change: Change
}

final class UpdateTeamHandler {
    private let teamRepository: TeamRepository

    init(teamRepository: TeamRepository) {
        self.teamRepository = teamRepository
    }

    func handle(_ command: UpdateTeamCommand) {
        guard var team = teamRepository.getAll().first(where: { $0.id == command.teamId.rawValue }) else { return }
        switch command.change {
        case .rename(let name):
            team.name = name
        case .add(let catchId):
            guard !team.isFull else { return }
            team.memberIds = Team.normalizeMembers(team.memberIds + [catchId.rawValue])
        case .remove(let catchId):
            team.memberIds.removeAll { $0 == catchId.rawValue }
        }
        teamRepository.save(team)
    }
}
