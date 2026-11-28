import Foundation

struct TeamMember: Equatable {
    let battler: BattlerSummary
    let types: [PokemonType]
    let attackingTypes: [PokemonType]
}

struct TeamOverview: Equatable {
    let id: TeamID
    let name: String
    let members: [TeamMember]
    let averageReadiness: Int?
}

struct TypeCoverage: Equatable {
    let type: PokemonType
    let hitters: Int
}

struct TypeWeakness: Equatable {
    let type: PokemonType
    let weakCount: Int
    let resistCount: Int
}

struct TeamDetails: Equatable {
    let id: TeamID
    let name: String
    let members: [TeamMember]
    let coverage: [TypeCoverage]
    let sharedWeaknesses: [TypeWeakness]
    let averageReadiness: Int?
    let readyCount: Int

    var isFull: Bool {
        return members.count >= Team.maximumSize
    }
}

struct TeamMemberLookup {
    private let rankBattlers: RankBattlersHandler
    private let catchRepository: CatchRepository
    private let catchData: PokemonCatchData
    private let moveTyping: MoveTyping
    private let moveCategories: MoveCategories

    init(rankBattlers: RankBattlersHandler, catchRepository: CatchRepository, catchData: PokemonCatchData, moveTyping: MoveTyping, moveCategories: MoveCategories) {
        self.rankBattlers = rankBattlers
        self.catchRepository = catchRepository
        self.catchData = catchData
        self.moveTyping = moveTyping
        self.moveCategories = moveCategories
    }

    func findAllBattlers() -> [TeamMember] {
        let catchesById = Dictionary(catchRepository.getAll().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return rankBattlers.handle(RankBattlersQuery(ranking: .readiness, level: .fifty, showsBestOfEachSpecies: false)).battlers.compactMap { battler in
            catchesById[battler.id.rawValue].map { makeMember(battler, caught: $0) }
        }
    }

    func findMembers(of team: Team, in battlers: [TeamMember]) -> [TeamMember] {
        let battlersById = Dictionary(battlers.map { ($0.battler.id.rawValue, $0) }, uniquingKeysWith: { first, _ in first })
        return team.memberIds.compactMap { battlersById[$0] }
    }

    static func makeAnalysis(of members: [TeamMember]) -> TeamAnalysis {
        return TeamAnalysis(members: members.map {
            TeamAnalysis.Member(types: $0.types, attackingTypes: Set($0.attackingTypes), readiness: $0.battler.readiness)
        })
    }

    private func makeMember(_ battler: BattlerSummary, caught: Catch) -> TeamMember {
        let types = (catchData.findProfile(of: caught.number, formId: caught.formId)?.types ?? []).compactMap(PokemonType.init(name:))
        var attackingTypes = [PokemonType]()
        for move in caught.moves where moveCategories.findCategory(of: move) != .status {
            if let type = moveTyping.findType(of: move), !attackingTypes.contains(type) {
                attackingTypes.append(type)
            }
        }
        return TeamMember(battler: battler, types: types, attackingTypes: attackingTypes)
    }
}
