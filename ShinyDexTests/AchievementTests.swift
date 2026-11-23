import XCTest
@testable import ShinyDex

final class AchievementTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func makeCatch(_ number: Int = 0, game: Games = .Scarlet, method: HuntMethod = .Encounters, encounters: Int = 500, charm: Bool = false, date: Date? = nil,
                           ball: String = "poke", isFailed: Bool = false, gender: Gender? = nil, formId: String? = nil) -> Catch {
        return Catch(id: UUID(), number: number, caughtBall: ball, game: game, huntMethod: method, encounters: encounters, isShinyCharmActive: charm,
                     caughtDate: date, isFailed: isFailed, evs: EffortValues(), evolvedFrom: nil, gender: gender, formId: formId)
    }

    private func evaluate(_ catches: [Catch], configure: (inout AchievementFacts) -> Void = { _ in }) -> [AchievementKind: Achievement] {
        var facts = AchievementFacts(catches: catches)
        facts.calendar = calendar
        configure(&facts)
        return Dictionary(uniqueKeysWithValues: AchievementRules.evaluate(facts).map { ($0.kind, $0) })
    }

    // MARK: Tiers

    func test_tiersUnlockAsTheValueReachesEachTarget() {
        let achievement = Achievement(kind: .shinyHoarder, category: .collecting, targets: [10, 50, 100], value: 57)

        XCTAssertEqual(achievement.unlockedTierCount, 2)
        XCTAssertTrue(achievement.isUnlocked)
        XCTAssertFalse(achievement.isComplete)
        XCTAssertEqual(achievement.nextTarget, 100)
        XCTAssertEqual(achievement.currentTarget, 100)
    }

    func test_everyAchievementIsListedOnce_andNothingIsUnlockedWithoutData() {
        let achievements = AchievementRules.evaluate(AchievementFacts(catches: []))

        XCTAssertEqual(Set(achievements.map { $0.kind }).count, achievements.count)
        XCTAssertEqual(achievements.filter { $0.isUnlocked }, [])
        XCTAssertEqual(achievements.filter { $0.isHidden }.map { $0.kind }, [.byTheBook, .modernClassic, .palindrome, .midnightSparkle, .roundNumber])
    }

    // MARK: Collecting

    func test_collectingCountsCaughtShinies_butNotOnesThatGotAway() {
        let catches = (0..<12).map { makeCatch($0) } + [makeCatch(20, isFailed: true)]

        let achievements = evaluate(catches)

        XCTAssertEqual(achievements[.shinyHoarder]?.value, 12)
        XCTAssertEqual(achievements[.shinyHoarder]?.unlockedTierCount, 1)
        XCTAssertEqual(achievements[.regionalMaster(region: 0)]?.value, 12)
        XCTAssertEqual(achievements[.regionalMaster(region: 0)]?.currentTarget, 151)
        XCTAssertEqual(achievements[.itGotAway]?.isUnlocked, true)
    }

    func test_formsLinesGendersAndBalls() {
        let forms = PokemonForms(formsByNumber: [5: SpeciesForms(defaultName: nil, alternates: [PokemonForm(id: "alola", name: "Alolan")])])
        let catches = [
            makeCatch(5, ball: "master"), makeCatch(5, ball: "moon", formId: "alola"),
            makeCatch(0, gender: .male), makeCatch(0, gender: .female), makeCatch(1)
        ]

        let achievements = evaluate(catches) { facts in
            facts.forms = forms
            facts.evolutions = Evolutions(evolvesFrom: [-1, 0, -1, -1, -1, -1])
            facts.ballNames = ["poke", "master", "moon", "fast"]
        }

        XCTAssertEqual(achievements[.formFanatic]?.isUnlocked, true)
        XCTAssertEqual(achievements[.familyReunion]?.isUnlocked, true)
        XCTAssertEqual(achievements[.genderBalance]?.isUnlocked, true)
        XCTAssertEqual(achievements[.masterClass]?.isUnlocked, true)
        XCTAssertEqual(achievements[.ballCollector]?.value, 3)
        XCTAssertEqual(achievements[.apricornAesthetic]?.value, 1)
    }

    // MARK: Hunting

    func test_huntingAchievements() {
        let catches = [
            makeCatch(0, game: .Platinum, encounters: 1),
            makeCatch(1, encounters: 12_000, charm: true),
            makeCatch(2, method: .Masuda, encounters: 300),
            makeCatch(3, encounters: 2_000, date: makeDate(2025, 3, 1), isFailed: true),
            makeCatch(3, encounters: 900, date: makeDate(2025, 4, 1))
        ]

        let achievements = evaluate(catches) { $0.encountersInProgress = 86 }

        XCTAssertEqual(achievements[.firstTry]?.isUnlocked, true)
        XCTAssertEqual(achievements[.lightningStrike]?.unlockedTierCount, 2)
        XCTAssertEqual(achievements[.marathon]?.isUnlocked, true)
        XCTAssertEqual(achievements[.againstAllOdds]?.isUnlocked, true)
        XCTAssertEqual(achievements[.dedicated]?.value, 1 + 12_000 + 300 + 2_000 + 900 + 86)
        XCTAssertEqual(achievements[.methodActor]?.value, 2)
        XCTAssertEqual(achievements[.unfinishedBusiness]?.isUnlocked, true)
    }

    func test_gettingAwayAfterTheCatch_isNotUnfinishedBusiness() {
        let catches = [makeCatch(3, date: makeDate(2025, 4, 1)), makeCatch(3, date: makeDate(2025, 5, 1), isFailed: true)]

        XCTAssertEqual(evaluate(catches)[.unfinishedBusiness]?.isUnlocked, false)
    }

    // MARK: Consistency

    func test_goalsAnniversariesAndMonths() {
        let catches = [makeCatch(0, date: makeDate(2024, 6, 9)), makeCatch(1, date: makeDate(2025, 6, 9)), makeCatch(2, date: makeDate(2025, 7, 1)),
                       makeCatch(3, date: makeDate(2025, 8, 1), isFailed: true)]

        let achievements = evaluate(catches) { facts in
            facts.yearlyGoals = [YearlyGoal(year: 2025, target: 3), YearlyGoal(year: 2024, target: 2)]
            facts.longestHuntingDayStreak = 8
        }

        XCTAssertEqual(achievements[.goalGetter]?.isUnlocked, true)
        XCTAssertEqual(achievements[.overachiever]?.isUnlocked, false)
        XCTAssertEqual(achievements[.anniversary]?.isUnlocked, true)
        XCTAssertEqual(achievements[.everyMonth]?.value, 2)
        XCTAssertEqual(achievements[.dailyGrind]?.unlockedTierCount, 1)
    }

    func test_drySpellSurvivor_onlyCountsStreaksThatEnded() {
        let first = makeCatch(0)
        first.encounterTotalAtFind = 5_000
        let second = makeCatch(1)
        second.encounterTotalAtFind = 26_000

        XCTAssertEqual(evaluate([first, second])[.drySpellSurvivor]?.value, 21_000)
        XCTAssertEqual(evaluate([first])[.drySpellSurvivor]?.isUnlocked, false)
    }

    // MARK: Games

    func test_gamesGenerationsAndPairs() {
        let catches = [makeCatch(0, game: .Red), makeCatch(1, game: .Blue), makeCatch(2, game: .Scarlet)]

        let achievements = evaluate(catches)

        XCTAssertEqual(achievements[.retro]?.isUnlocked, true)
        XCTAssertEqual(achievements[.sameGameTwice]?.isUnlocked, true)
        XCTAssertEqual(achievements[.generational]?.value, 2)
        XCTAssertEqual(achievements[.timeTraveller]?.value, 3)
    }

    // MARK: Battle

    func test_battleAchievements() {
        let ready = makeCatch(0)
        ready.ivs = makeIVs([31, 31, 31, 31, 31, 31])
        ready.evs = makeEVs([4, 252, 0, 0, 0, 252])
        ready.nature = .adamant
        ready.moves = [1, 2, 3, 4]
        let slow = makeCatch(1)
        slow.ivs = makeIVs([31, 31, 31, 31, 31, 0])
        slow.nature = .brave
        let retro = makeCatch(2, game: .Gold)
        retro.ivs = makeIVs([15, 15, 15, 15, 15, 15])

        let achievements = evaluate([ready, slow, retro])

        XCTAssertEqual(achievements[.battleReady]?.isUnlocked, true)
        XCTAssertEqual(achievements[.fullTeam]?.value, 1)
        XCTAssertEqual(achievements[.perfection]?.isUnlocked, true)
        XCTAssertEqual(achievements[.fullyTrained]?.isUnlocked, true)
        XCTAssertEqual(achievements[.trickRoomSpecialist]?.isUnlocked, true)
        XCTAssertEqual(achievements[.natureLover]?.value, 2)
        XCTAssertEqual(achievements[.hiddenPowerCollector]?.value, 2)
    }

    // MARK: Exactly the odds

    func test_exactOdds_countPlainHuntsAtFullOddsOnly() {
        let achievements = evaluate([
            makeCatch(0, game: .Platinum, encounters: 8_192),
            makeCatch(1, game: .Scarlet, encounters: 4_096),
            makeCatch(2, game: .Platinum, encounters: 4_096),
            makeCatch(3, game: .Scarlet, encounters: 8_192),
            makeCatch(4, game: .Platinum, encounters: 24_576)
        ])

        XCTAssertEqual(achievements[.byTheBook]?.isUnlocked, true)
        XCTAssertEqual(achievements[.modernClassic]?.isUnlocked, true)
        XCTAssertEqual(achievements[.halfwayThere]?.isUnlocked, true)
        XCTAssertEqual(achievements[.doubleTrouble]?.isUnlocked, true)
        XCTAssertEqual(achievements[.tripleThreat]?.isUnlocked, true)
    }

    func test_exactOdds_ignoreMethodsAndTheShinyCharm() {
        let achievements = evaluate([
            makeCatch(0, game: .Scarlet, method: .Masuda, encounters: 4_096),
            makeCatch(1, game: .Scarlet, encounters: 1_365, charm: true),
            makeCatch(2, game: .Scarlet, encounters: 2_730, charm: true)
        ])

        XCTAssertEqual(achievements[.modernClassic]?.isUnlocked, false)
        XCTAssertEqual(achievements[.doubleTrouble]?.isUnlocked, false)
    }

    // MARK: Secrets

    func test_secretAchievements() {
        let achievements = evaluate([
            makeCatch(0, encounters: 4_554),
            makeCatch(1, encounters: 5_000, date: makeDate(2026, 1, 1))
        ])

        XCTAssertEqual(achievements[.palindrome]?.isUnlocked, true)
        XCTAssertEqual(achievements[.roundNumber]?.isUnlocked, true)
        XCTAssertEqual(achievements[.midnightSparkle]?.isUnlocked, true)
        XCTAssertFalse(AchievementRules.isPalindrome(121))
        XCTAssertFalse(AchievementRules.isPalindrome(1_234))
    }

    func test_nextUp_listsTheClosestAchievementsInProgress() {
        let overview = AchievementsOverview(achievements: [
            Achievement(kind: .shinyHoarder, category: .collecting, targets: [10], value: 9, countsProgress: true),
            Achievement(kind: .charmed, category: .hunting, targets: [25], value: 5, countsProgress: true),
            Achievement(kind: .nicknamer, category: .features, targets: [10], value: 0, countsProgress: true),
            Achievement(kind: .natureLover, category: .battle, targets: [25], value: 25, countsProgress: true),
            Achievement(kind: .everyMonth, category: .consistency, targets: [12], value: 6, countsProgress: true),
            Achievement(kind: .methodActor, category: .hunting, targets: [9], value: 8, countsProgress: true),
            Achievement(kind: .firstTry, category: .hunting, targets: [1], value: 0)
        ])

        XCTAssertEqual(overview.nextUp.map { $0.kind }, [.shinyHoarder, .methodActor, .everyMonth])
    }

    // MARK: Unlocking catches

    func test_tieredAchievements_listTheCatchThatReachedEachTier() {
        let catches = (0..<12).map { makeCatch($0, date: makeDate(2025, 1, $0 + 1)) }

        let hoarder = evaluate(catches.shuffled())[.shinyHoarder]!

        XCTAssertEqual(hoarder.catchIds, [catches[9].id])
        XCTAssertEqual(evaluate(catches)[.firstSparkle]?.catchIds, [catches[0].id])
    }

    func test_catchesWithKnownDates_comeBeforeUndatedOnes() {
        let undated = makeCatch(0)
        let later = makeCatch(1, date: makeDate(2025, 6, 1))
        let earliest = makeCatch(2, date: makeDate(2024, 2, 1))

        let achievements = evaluate([undated, later, earliest])

        XCTAssertEqual(achievements[.firstSparkle]?.catchIds, [earliest.id])
        XCTAssertEqual(CatchRules.sortedByKnownDateFirst([undated, later, earliest]).map { $0.id }, [earliest.id, later.id, undated.id])
    }

    func test_setAchievements_listTheFirstCatchOfEachMember() {
        let first = makeCatch(0, date: makeDate(2025, 1, 1))
        first.nature = .adamant
        let repeatNature = makeCatch(1, date: makeDate(2025, 1, 2))
        repeatNature.nature = .adamant
        let second = makeCatch(2, date: makeDate(2025, 1, 3))
        second.nature = .timid

        XCTAssertEqual(evaluate([second, repeatNature, first])[.natureLover]?.catchIds, [first.id, second.id])
    }

    func test_matchingAndPairedAchievements_listTheirCatches() {
        let male = makeCatch(0, date: makeDate(2025, 1, 1), gender: .male)
        let female = makeCatch(0, date: makeDate(2025, 1, 2), gender: .female)
        let firstTry = makeCatch(1, encounters: 1)
        let gotAway = makeCatch(2, date: makeDate(2025, 2, 1), isFailed: true)
        let caughtLater = makeCatch(2, date: makeDate(2025, 3, 1))

        let achievements = evaluate([female, firstTry, male, caughtLater, gotAway])

        XCTAssertEqual(achievements[.genderBalance]?.catchIds, [male.id, female.id])
        XCTAssertEqual(achievements[.firstTry]?.catchIds, [firstTry.id])
        XCTAssertEqual(achievements[.unfinishedBusiness]?.catchIds, [gotAway.id, caughtLater.id])
        XCTAssertEqual(achievements[.itGotAway]?.catchIds, [gotAway.id])
    }

    func test_goalGetter_listsTheCatchThatReachedTheGoal() {
        let catches = (1...3).map { makeCatch($0, date: makeDate(2025, $0, 1)) }

        let achievements = evaluate(catches) { $0.yearlyGoals = [YearlyGoal(year: 2025, target: 2)] }

        XCTAssertEqual(achievements[.goalGetter]?.catchIds, [catches[1].id])
    }

    // MARK: Claiming

    private func makeClaimHandler(catches: InMemoryCatchRepository, store: InMemoryKeyValueStore) -> ClaimNewAchievementsHandler {
        return ClaimNewAchievementsHandler(getAchievements: makeHandler(catches: catches), keyValueStore: store)
    }

    private func makeHandler(catches: InMemoryCatchRepository, pokemon: InMemoryPokemonRepository = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur"])) -> GetAchievementsHandler {
        let folder = InMemoryBackupFolder()
        return GetAchievementsHandler(
            catchRepository: catches, pokemonRepository: pokemon, huntRepository: InMemoryHuntRepository(), yearlyGoalRepository: InMemoryYearlyGoalRepository(),
            dailyEncountersRepository: InMemoryDailyEncountersRepository(),
            getJourneys: GetJourneysHandler(journeyRepository: InMemoryJourneyRepository(), catchRepository: catches, pokemonRepository: pokemon),
            getBingoBoards: GetBingoBoardsHandler(bingoBoardRepository: InMemoryBingoBoardRepository(), catchRepository: catches),
            getBallNames: GetBallNamesHandler(resourceLoader: StubResourceLoader()),
            getAutomaticBackupStatus: GetAutomaticBackupStatusHandler(backupFolder: folder, keyValueStore: InMemoryKeyValueStore()),
            calendar: calendar)
    }

    func test_claiming_isSilentTheFirstTime_thenReportsEachNewUnlockOnce() {
        let catches = InMemoryCatchRepository()
        let store = InMemoryKeyValueStore()
        catches.insert(makeCatch(0))
        let handler = makeClaimHandler(catches: catches, store: store)

        XCTAssertEqual(handler.handle(ClaimNewAchievementsCommand()), [])

        catches.insert(makeCatch(1, ball: "master"))
        let unlocked = handler.handle(ClaimNewAchievementsCommand())

        XCTAssertEqual(unlocked.map { $0.achievement.kind }, [.masterClass])
        XCTAssertEqual(unlocked.first?.tier, 1)
        XCTAssertEqual(handler.handle(ClaimNewAchievementsCommand()), [])
    }

    func test_claimKeys_stayTheSame() {
        XCTAssertEqual(ClaimNewAchievementsHandler.makeClaimKey(for: .shinyHoarder, tier: 2), "achievementClaimed.shinyHoarder.2")
        XCTAssertEqual(ClaimNewAchievementsHandler.makeClaimKey(for: .regionalMaster(region: 3), tier: 1), "achievementClaimed.regionalMaster(region: 3).1")
    }

    func test_details_includeTheUnlockingCatches() {
        let catches = InMemoryCatchRepository()
        let caught = makeCatch(1, encounters: 1)
        catches.insert(caught)
        let pokemon = InMemoryPokemonRepository(names: ["Bulbasaur", "Ivysaur"])

        let details = GetAchievementDetailsHandler(getAchievements: makeHandler(catches: catches, pokemon: pokemon), catchRepository: catches, pokemonRepository: pokemon)
            .handle(GetAchievementDetailsQuery(kind: .firstTry))

        XCTAssertEqual(details?.achievement.isUnlocked, true)
        XCTAssertEqual(details?.catches.map { $0.id.rawValue }, [caught.id])
        XCTAssertEqual(details?.catches.first?.pokemonName, "Ivysaur")
    }

    // MARK: Handler

    func test_handlerGathersFactsFromAcrossTheApp() {
        let catches = InMemoryCatchRepository()
        catches.insert(makeCatch(0))
        let pokemon = InMemoryPokemonRepository(names: ["Bulbasaur"])
        let hunts = InMemoryHuntRepository()
        hunts.save(Hunt(name: "Lots", indexes: [0, 1, 2, 3, 4], priority: 0, isCollapsed: false))
        let resources = StubResourceLoader()
        resources.textResources["pokeballs"] = ["poke", "none", "great"]
        let folder = InMemoryBackupFolder()
        try? folder.choose(URL(fileURLWithPath: "/tmp/backups"))
        let journeys = InMemoryJourneyRepository()
        let boards = InMemoryBingoBoardRepository()

        let overview = GetAchievementsHandler(
            catchRepository: catches, pokemonRepository: pokemon, huntRepository: hunts, yearlyGoalRepository: InMemoryYearlyGoalRepository(),
            dailyEncountersRepository: InMemoryDailyEncountersRepository(),
            getJourneys: GetJourneysHandler(journeyRepository: journeys, catchRepository: catches, pokemonRepository: pokemon),
            getBingoBoards: GetBingoBoardsHandler(bingoBoardRepository: boards, catchRepository: catches),
            getBallNames: GetBallNamesHandler(resourceLoader: resources),
            getAutomaticBackupStatus: GetAutomaticBackupStatusHandler(backupFolder: folder, keyValueStore: InMemoryKeyValueStore()),
            calendar: calendar
        ).handle(GetAchievementsQuery())
        let byKind = Dictionary(uniqueKeysWithValues: overview.achievements.map { ($0.kind, $0) })

        XCTAssertEqual(byKind[.firstSparkle]?.isUnlocked, true)
        XCTAssertEqual(byKind[.multitasker]?.isUnlocked, true)
        XCTAssertEqual(byKind[.archivist]?.isUnlocked, true)
        XCTAssertEqual(byKind[.ballCollector]?.value, 1)
        XCTAssertEqual(overview.unlockedCount, overview.achievements.filter { $0.isUnlocked }.count)
    }
}
