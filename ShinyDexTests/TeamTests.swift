import XCTest
@testable import ShinyDex

final class PokemonTypeTests: XCTestCase {
    func test_multiplier_followsTheChart_includingImmunities() {
        XCTAssertEqual(PokemonType.water.calculateMultiplier(against: .fire), 2)
        XCTAssertEqual(PokemonType.fire.calculateMultiplier(against: .water), 0.5)
        XCTAssertEqual(PokemonType.normal.calculateMultiplier(against: .ghost), 0)
        XCTAssertEqual(PokemonType.dragon.calculateMultiplier(against: .fairy), 0)
        XCTAssertEqual(PokemonType.electric.calculateMultiplier(against: .psychic), 1)
    }

    func test_multiplier_againstTwoTypes_multipliesBoth() {
        XCTAssertEqual(PokemonType.ice.calculateMultiplier(against: [.dragon, .flying]), 4)
        XCTAssertEqual(PokemonType.ground.calculateMultiplier(against: [.fire, .flying]), 0)
        XCTAssertEqual(PokemonType.rock.calculateMultiplier(against: [.fire, .ground]), 1)
    }

    func test_name_matchesStoredTypeNames_ignoringCase() {
        XCTAssertEqual(PokemonType(name: "grass"), .grass)
        XCTAssertEqual(PokemonType(name: "Fairy"), .fairy)
        XCTAssertNil(PokemonType(name: "shadow"))
        XCTAssertEqual(PokemonType.psychic.name, "Psychic")
    }
}

final class TeamAnalysisTests: XCTestCase {
    func test_coverage_countsMembersWithASuperEffectiveMove_perDefendingType() {
        let analysis = TeamAnalysis(members: [
            makeMember(types: [.water], attacking: [.water, .ice]),
            makeMember(types: [.electric], attacking: [.electric, .ice])
        ])

        XCTAssertEqual(analysis.coverage.first { $0.defender == .dragon }?.hitters, 2)
        XCTAssertEqual(analysis.coverage.first { $0.defender == .fire }?.hitters, 1)
        XCTAssertTrue(analysis.uncoveredTypes.contains(.steel))
        XCTAssertFalse(analysis.coveredTypes.contains(.steel))
    }

    func test_sharedWeaknesses_needTwoWeakMembers_andMoreWeakThanResisting() {
        let analysis = TeamAnalysis(members: [
            makeMember(types: [.water]),
            makeMember(types: [.water, .flying]),
            makeMember(types: [.grass])
        ])

        XCTAssertEqual(analysis.sharedWeaknesses.map { $0.attacker }, [.electric])
        XCTAssertEqual(analysis.sharedWeaknesses.first, TeamAnalysis.Weakness(attacker: .electric, weakCount: 2, resistCount: 1))
    }

    func test_sharedWeaknesses_leaveOutTypesTheTeamResistsAsOftenAsItIsWeak() {
        let analysis = TeamAnalysis(members: [
            makeMember(types: [.grass]),
            makeMember(types: [.grass]),
            makeMember(types: [.fire]),
            makeMember(types: [.dragon])
        ])

        XCTAssertFalse(analysis.sharedWeaknesses.contains { $0.attacker == .fire })
        XCTAssertTrue(analysis.sharedWeaknesses.contains { $0.attacker == .ice })
    }

    func test_averageReadiness_isRounded_andNilForAnEmptyTeam() {
        XCTAssertEqual(TeamAnalysis(members: [makeMember(readiness: 80), makeMember(readiness: 75)]).averageReadiness, 78)
        XCTAssertNil(TeamAnalysis(members: []).averageReadiness)
    }

    fileprivate func makeMember(types: [PokemonType] = [.normal], attacking: Set<PokemonType> = [], readiness: Int = 0) -> TeamAnalysis.Member {
        return TeamAnalysis.Member(types: types, attackingTypes: attacking, readiness: readiness)
    }
}

final class TeamHandlerTests: XCTestCase {
    fileprivate var teams: InMemoryTeamRepository!
    fileprivate var catches: InMemoryCatchRepository!
    fileprivate var pokemon: InMemoryPokemonRepository!

    override func setUp() {
        super.setUp()
        teams = InMemoryTeamRepository()
        catches = InMemoryCatchRepository()
        pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander"])
    }

    func test_team_keepsAtMostSixUniqueMembers_inTheOrderTheyWereAdded() {
        let teamId = CreateTeamHandler(teamRepository: teams).handle(CreateTeamCommand(name: "Doubles"))
        let ids = (0..<8).map { _ in CatchID(rawValue: UUID()) }
        let update = UpdateTeamHandler(teamRepository: teams)
        update.handle(UpdateTeamCommand(teamId: teamId, change: .add(ids[0])))
        update.handle(UpdateTeamCommand(teamId: teamId, change: .add(ids[0])))
        ids.dropFirst().forEach { update.handle(UpdateTeamCommand(teamId: teamId, change: .add($0))) }

        XCTAssertEqual(teams.getAll().first?.memberIds, ids.prefix(6).map { $0.rawValue })

        update.handle(UpdateTeamCommand(teamId: teamId, change: .remove(ids[2])))
        update.handle(UpdateTeamCommand(teamId: teamId, change: .rename("VGC")))
        XCTAssertEqual(teams.getAll().first?.memberIds, [0, 1, 3, 4, 5].map { ids[$0].rawValue })
        XCTAssertEqual(teams.getAll().first?.name, "VGC")

        DeleteTeamHandler(teamRepository: teams).handle(DeleteTeamCommand(teamId: teamId))
        XCTAssertTrue(teams.getAll().isEmpty)
    }

    func test_getTeam_mapsMembersWithTheirTypesAndDamagingMoveTypes_andSkipsMissingCatches() {
        let venusaur = makeBattler(number: 2, moves: [1, 2, 3])
        let charmander = makeBattler(number: 3, moves: [4])
        let teamId = CreateTeamHandler(teamRepository: teams).handle(CreateTeamCommand(name: "Doubles"))
        let update = UpdateTeamHandler(teamRepository: teams)
        [charmander.id, UUID(), venusaur.id].forEach { update.handle(UpdateTeamCommand(teamId: teamId, change: .add(CatchID(rawValue: $0)))) }

        let details = GetTeamHandler(teamRepository: teams, lookup: makeLookup()).handle(GetTeamQuery(teamId: teamId))

        XCTAssertEqual(details?.members.map { $0.battler.number }, [3, 2])
        XCTAssertEqual(details?.members.last?.types, [.grass, .poison])
        XCTAssertEqual(details?.members.last?.attackingTypes, [.grass, .poison])
        XCTAssertEqual(details?.coverage.count, PokemonType.allCases.count)
        XCTAssertEqual(details?.coverage.first { $0.type == .water }?.hitters, 1)
        XCTAssertNotNil(details?.averageReadiness)
    }

    func test_candidates_leaveOutCurrentMembers() {
        let venusaur = makeBattler(number: 2, moves: [1])
        let charmander = makeBattler(number: 3, moves: [4])
        let teamId = CreateTeamHandler(teamRepository: teams).handle(CreateTeamCommand(name: "Doubles"))
        UpdateTeamHandler(teamRepository: teams).handle(UpdateTeamCommand(teamId: teamId, change: .add(CatchID(rawValue: venusaur.id))))

        let candidates = GetTeamCandidatesHandler(teamRepository: teams, lookup: makeLookup()).handle(GetTeamCandidatesQuery(teamId: teamId))

        XCTAssertEqual(candidates.map { $0.battler.id.rawValue }, [charmander.id])
    }

    fileprivate func makeBattler(number: Int, moves: [Int]) -> Catch {
        let caught = Catch(number: number, caughtBall: "poke", game: .Scarlet, huntMethod: .Encounters, encounters: 1, isShinyCharmActive: false, caughtDate: nil)
        caught.ivs = IndividualValues(encoded: "31,31,31,31,31,31")
        caught.moves = moves
        catches.insert(caught)
        return caught
    }

    fileprivate func makeLookup() -> TeamMemberLookup {
        let catchData = PokemonCatchData(profilesByNumber: [
            2: SpeciesCatchProfiles(standard: CatchProfile(catchRate: 45, types: ["grass", "poison"], weightInHectograms: 1000), profilesByFormId: [:]),
            3: SpeciesCatchProfiles(standard: CatchProfile(catchRate: 45, types: ["fire"], weightInHectograms: 85), profilesByFormId: [:])
        ])
        let moveTyping = MoveTyping(typesById: [1: .grass, 2: .poison, 3: .normal, 4: .fire])
        let moveCategories = MoveCategories(categoriesById: [1: .special, 2: .physical, 3: .status, 4: .special])
        return TeamMemberLookup(rankBattlers: RankBattlersHandler(catchRepository: catches, pokemonRepository: pokemon, moveCategories: moveCategories),
                                catchRepository: catches, catchData: catchData, moveTyping: moveTyping, moveCategories: moveCategories)
    }
}
