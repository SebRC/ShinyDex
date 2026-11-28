import Foundation

struct GetTeamsQuery {}

final class GetTeamsHandler {
    private let teamRepository: TeamRepository
    private let lookup: TeamMemberLookup

    init(teamRepository: TeamRepository, lookup: TeamMemberLookup) {
        self.teamRepository = teamRepository
        self.lookup = lookup
    }

    func handle(_ query: GetTeamsQuery) -> [TeamOverview] {
        let battlers = lookup.findAllBattlers()
        return teamRepository.getAll()
            .sorted { $0.createdDate < $1.createdDate }
            .map { team in
                let members = lookup.findMembers(of: team, in: battlers)
                return TeamOverview(id: TeamID(rawValue: team.id), name: team.name, members: members,
                                    averageReadiness: TeamMemberLookup.makeAnalysis(of: members).averageReadiness)
            }
    }
}
