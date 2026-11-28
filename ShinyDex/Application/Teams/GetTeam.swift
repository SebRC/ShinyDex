import Foundation

struct GetTeamQuery {
    let teamId: TeamID
}

final class GetTeamHandler {
    private let teamRepository: TeamRepository
    private let lookup: TeamMemberLookup

    init(teamRepository: TeamRepository, lookup: TeamMemberLookup) {
        self.teamRepository = teamRepository
        self.lookup = lookup
    }

    func handle(_ query: GetTeamQuery) -> TeamDetails? {
        guard let team = teamRepository.getAll().first(where: { $0.id == query.teamId.rawValue }) else { return nil }
        let members = lookup.findMembers(of: team, in: lookup.findAllBattlers())
        let analysis = TeamMemberLookup.makeAnalysis(of: members)
        return TeamDetails(
            id: query.teamId,
            name: team.name,
            members: members,
            coverage: analysis.coverage.map { TypeCoverage(type: $0.defender, hitters: $0.hitters) },
            sharedWeaknesses: analysis.sharedWeaknesses.map { TypeWeakness(type: $0.attacker, weakCount: $0.weakCount, resistCount: $0.resistCount) },
            averageReadiness: analysis.averageReadiness,
            readyCount: members.filter { $0.battler.badges.contains(.battleReady) }.count)
    }
}
