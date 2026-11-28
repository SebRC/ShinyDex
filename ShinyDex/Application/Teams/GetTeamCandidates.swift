import Foundation

struct GetTeamCandidatesQuery {
    let teamId: TeamID
}

final class GetTeamCandidatesHandler {
    private let teamRepository: TeamRepository
    private let lookup: TeamMemberLookup

    init(teamRepository: TeamRepository, lookup: TeamMemberLookup) {
        self.teamRepository = teamRepository
        self.lookup = lookup
    }

    func handle(_ query: GetTeamCandidatesQuery) -> [TeamMember] {
        let memberIds = Set(teamRepository.getAll().first { $0.id == query.teamId.rawValue }?.memberIds ?? [])
        return lookup.findAllBattlers().filter { !memberIds.contains($0.battler.id.rawValue) }
    }
}
