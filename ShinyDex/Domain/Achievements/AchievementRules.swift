import Foundation

enum AchievementRules {
    static let apricornBalls: Set<String> = ["fast", "friend", "heavy", "level", "love", "lure", "moon"]
    static let masterBall = "master"
    static let roundEncounterCounts: Set<Int> = [1_000, 5_000, 10_000]
    static let minimumPalindromeEncounters = 1_000
    static let marathonEncounters = 10_000
    static let drySpellEncounters = 20_000
    static let exactOdds = [CatchOdds.fullOdds, CatchOdds.fullOdds / 2]
    static let versionPairs: [(Games, Games)] = [
        (.Red, .Blue), (.Gold, .Silver), (.Ruby, .Sapphire), (.FireRed, .LeafGreen), (.Diamond, .Pearl), (.Heartgold, .SoulSilver),
        (.Black, .White), (.Black2, .White2), (.X, .Y), (.OmegaRuby, .AlphaSapphire), (.Sun, .Moon), (.UltraSun, .UltraMoon),
        (.LetsGoPikachu, .LetsGoEevee), (.Sword, .Shield), (.BrilliantDiamond, .ShiningPearl), (.Scarlet, .Violet)
    ]
    static let lastGenerationWithDeterminantValues = 2

    static func evaluate(_ facts: AchievementFacts) -> [Achievement] {
        let context = Context(facts: facts)
        return evaluateCollecting(context) + evaluateHunting(context) + evaluateConsistency(context) + evaluateGames(context)
            + evaluateBattle(context) + evaluateFeatures(context) + evaluateOdds(context) + evaluateSecrets(context)
    }

    // MARK: Collecting

    fileprivate static func evaluateCollecting(_ context: Context) -> [Achievement] {
        let caught = context.caught
        let regions = PokedexRegions.all.compactMap { region in
            PokedexRegions.getNumbers(inRegion: region).map { range in
                makeTieredByDistinct(.regionalMaster(region: region), .collecting, targets: [range.count], caught.filter { range.contains($0.number) }) { $0.number }
            }
        }
        let nationalDex = Set(PokedexRegions.all.compactMap(PokedexRegions.getNumbers(inRegion:)).flatMap { $0 })
        let ballCatches = caught.filter { context.facts.ballNames.contains($0.caughtBall) }
        return [
            makeTieredByDistinct(.firstSparkle, .collecting, targets: [1], caught, countsProgress: false) { $0.id },
            makeTieredByDistinct(.shinyHoarder, .collecting, targets: [10, 50, 100, 250], caught) { $0.id }
        ] + regions + [
            makeTieredByDistinct(.livingDex, .collecting, targets: [nationalDex.count], caught.filter { nationalDex.contains($0.number) }) { $0.number },
            makeFormFanatic(caught, forms: context.facts.forms),
            makeFamilyReunion(caught, evolutions: context.facts.evolutions),
            makeGenderBalance(caught),
            makeTieredByDistinct(.ballCollector, .collecting, targets: [5, 15, max(context.facts.ballNames.count, 16)], ballCatches) { $0.caughtBall },
            makeSetByDistinct(.apricornAesthetic, .collecting, target: apricornBalls.count, caught.filter { apricornBalls.contains($0.caughtBall) }) { $0.caughtBall },
            makeMatching(.masterClass, .collecting, caught.filter { $0.caughtBall == masterBall })
        ]
    }

    fileprivate static func makeFormFanatic(_ caught: [Catch], forms: PokemonForms) -> Achievement {
        let catchesByNumber = Dictionary(grouping: CatchRules.sortedOldestFirst(caught), by: { $0.number })
        var completedCatchIds = [UUID]()
        var completedCount = 0
        for number in forms.numbersWithForms {
            guard let species = forms.getForms(of: number), let speciesCatches = catchesByNumber[number] else { continue }
            let everyForm: [String?] = [nil] + species.alternates.map { $0.id }
            let firstOfEachForm = everyForm.compactMap { formId in speciesCatches.first { $0.formId == formId } }
            if (firstOfEachForm.count == everyForm.count) {
                completedCount += 1
                completedCatchIds += firstOfEachForm.map { $0.id }
            }
        }
        return Achievement(kind: .formFanatic, category: .collecting, targets: [1], value: completedCount, catchIds: completedCatchIds)
    }

    fileprivate static func makeFamilyReunion(_ caught: [Catch], evolutions: Evolutions) -> Achievement {
        let firstByNumber = Dictionary(CatchRules.sortedOldestFirst(caught).map { ($0.number, $0) }, uniquingKeysWith: { first, _ in first })
        let roots = Set(firstByNumber.keys.map(evolutions.getRoot)).sorted()
        let completeLines = roots.map(evolutions.getLine).filter { line in line.count > 1 && line.allSatisfy { firstByNumber[$0] != nil } }
        let catchIds = completeLines.flatMap { line in line.compactMap { firstByNumber[$0]?.id } }
        return Achievement(kind: .familyReunion, category: .collecting, targets: [1], value: completeLines.count, catchIds: catchIds)
    }

    fileprivate static func makeGenderBalance(_ caught: [Catch]) -> Achievement {
        let sorted = CatchRules.sortedOldestFirst(caught)
        let pairs = Dictionary(grouping: sorted, by: { $0.number }).sorted { $0.key < $1.key }.compactMap { _, catches -> [UUID]? in
            guard let male = catches.first(where: { $0.gender == .male }), let female = catches.first(where: { $0.gender == .female }) else { return nil }
            return [male.id, female.id]
        }
        return Achievement(kind: .genderBalance, category: .collecting, targets: [1], value: pairs.count, catchIds: pairs.flatMap { $0 })
    }

    // MARK: Hunting

    fileprivate static func evaluateHunting(_ context: Context) -> [Achievement] {
        let caught = context.caught
        let fewestEncounters = caught.map { $0.encounters }.filter { $0 > 0 }.min()
        let luckiestChance = caught.compactMap(CatchOdds.calculateChanceOfFindingSooner).min()
        let totalEncounters = context.facts.catches.reduce(0) { $0 + $1.encounters } + context.facts.encountersInProgress
        let lightningCatches = caught.filter { (1..<100).contains($0.encounters) }
        let luckyCatches = caught.filter { (CatchOdds.calculateChanceOfFindingSooner($0) ?? 100) <= 10 }
        return [
            Achievement(kind: .dedicated, category: .hunting, targets: [10_000, 100_000, 1_000_000], value: totalEncounters, countsProgress: true),
            makeMatching(.marathon, .hunting, context.facts.catches.filter { $0.encounters >= marathonEncounters }, value: context.facts.catches.map { $0.encounters }.max() ?? 0, targets: [marathonEncounters], countsProgress: true),
            makeMatching(.lightningStrike, .hunting, lightningCatches, value: fewestEncounters.map { ($0 < 100 ? 1 : 0) + ($0 < 10 ? 1 : 0) } ?? 0, targets: [1, 2]),
            makeMatching(.firstTry, .hunting, caught.filter { $0.encounters == 1 }),
            makeMatching(.beatTheOdds, .hunting, luckyCatches, value: luckiestChance.map { ($0 <= 10 ? 1 : 0) + ($0 <= 1 ? 1 : 0) } ?? 0, targets: [1, 2]),
            makeMatching(.againstAllOdds, .hunting, caught.filter(CatchOdds.isFullOddsHunt)),
            makeSetByDistinct(.methodActor, .hunting, target: HuntMethod.allCases.count, caught) { $0.huntMethod },
            makeTieredByDistinct(.charmed, .hunting, targets: [25], caught.filter { $0.isShinyCharmActive }) { $0.id },
            Achievement(kind: .multitasker, category: .hunting, targets: [5], value: context.facts.largestHuntSize, countsProgress: true),
            makeMatching(.itGotAway, .hunting, context.facts.catches.filter { $0.isFailed }),
            makeUnfinishedBusiness(context.facts.catches)
        ]
    }

    fileprivate static func makeUnfinishedBusiness(_ catches: [Catch]) -> Achievement {
        let sorted = CatchRules.sortedOldestFirst(catches)
        let pairs = Dictionary(grouping: sorted, by: { $0.number }).sorted { $0.key < $1.key }.compactMap { _, speciesCatches -> [UUID]? in
            for failed in speciesCatches where failed.isFailed {
                let later = speciesCatches.first { success in
                    guard !success.isFailed else { return false }
                    guard let failedDate = failed.caughtDate, let caughtDate = success.caughtDate else { return true }
                    return caughtDate >= failedDate
                }
                if let later = later {
                    return [failed.id, later.id]
                }
            }
            return nil
        }
        return Achievement(kind: .unfinishedBusiness, category: .hunting, targets: [1], value: pairs.count, catchIds: pairs.flatMap { $0 })
    }

    // MARK: Consistency

    fileprivate static func evaluateConsistency(_ context: Context) -> [Achievement] {
        let calendar = context.facts.calendar
        let datedCatches = CatchRules.sortedOldestFirst(context.facts.catches.filter { $0.caughtDate != nil })
        let foundByYear = Dictionary(grouping: datedCatches, by: { calendar.component(.year, from: $0.caughtDate!) })
        let goals = context.facts.yearlyGoals.filter { $0.target > 0 }.sorted { $0.year < $1.year }
        func findCatchesReaching(multiple: Int) -> [UUID] {
            return goals.compactMap { goal in
                let found = foundByYear[goal.year] ?? []
                let needed = goal.target * multiple
                return found.count >= needed ? found[needed - 1].id : nil
            }
        }
        let caughtDated = CatchRules.sortedOldestFirst(context.caught.filter { $0.caughtDate != nil })
        let byDate = Dictionary(grouping: caughtDated, by: { calendar.dateComponents([.month, .day], from: $0.caughtDate!) })
        let anniversaries = byDate.values.filter { Set($0.map { calendar.component(.year, from: $0.caughtDate!) }).count > 1 }
        let goalCatches = findCatchesReaching(multiple: 1)
        let doubledGoalCatches = findCatchesReaching(multiple: 2)
        return [
            Achievement(kind: .dailyGrind, category: .consistency, targets: [7, 30, 100], value: context.facts.longestHuntingDayStreak, countsProgress: true),
            Achievement(kind: .goalGetter, category: .consistency, targets: [1], value: goalCatches.count, catchIds: goalCatches),
            Achievement(kind: .overachiever, category: .consistency, targets: [1], value: doubledGoalCatches.count, catchIds: doubledGoalCatches),
            makeDrySpellSurvivor(context.facts.catches),
            Achievement(kind: .anniversary, category: .consistency, targets: [1], value: anniversaries.count,
                        catchIds: CatchRules.sortedOldestFirst(anniversaries.flatMap { $0 }).map { $0.id }),
            makeSetByDistinct(.everyMonth, .consistency, target: 12, caughtDated) { calendar.component(.month, from: $0.caughtDate!) }
        ]
    }

    fileprivate static func makeDrySpellSurvivor(_ catches: [Catch]) -> Achievement {
        let finds = catches.filter { $0.encounterTotalAtFind != nil }.sorted { $0.encounterTotalAtFind! < $1.encounterTotalAtFind! }
        let streaks = DryStreaks.findEndedStreaks(in: catches)
        let enders = zip(finds, streaks).filter { $0.1 >= drySpellEncounters }.map { $0.0.id }
        return Achievement(kind: .drySpellSurvivor, category: .consistency, targets: [drySpellEncounters], value: streaks.max() ?? 0, countsProgress: true, catchIds: enders)
    }

    // MARK: Games

    fileprivate static func evaluateGames(_ context: Context) -> [Achievement] {
        let caught = context.caught
        let allGenerations = Set(GamesList.games.values.map { $0.generation })
        let sorted = CatchRules.sortedOldestFirst(caught)
        let pairCatches = versionPairs.compactMap { pair -> [UUID]? in
            guard let first = sorted.first(where: { $0.game == pair.0 }), let second = sorted.first(where: { $0.game == pair.1 }) else { return nil }
            return [first.id, second.id]
        }
        return [
            makeSetByDistinct(.generational, .games, target: allGenerations.count, caught) { GamesList.games[$0.game]?.generation },
            makeTieredByDistinct(.timeTraveller, .games, targets: [10, 25, Games.allCases.count], caught) { $0.game },
            makeMatching(.retro, .games, caught.filter { (GamesList.games[$0.game]?.generation ?? 0) <= lastGenerationWithDeterminantValues }),
            Achievement(kind: .sameGameTwice, category: .games, targets: [1], value: pairCatches.count, catchIds: pairCatches.flatMap { $0 })
        ]
    }

    // MARK: Battle

    fileprivate static func evaluateBattle(_ context: Context) -> [Achievement] {
        let moveCategories = context.facts.moveCategories
        let battlers = context.caught.filter { (GamesList.games[$0.game]?.generation ?? 0) > lastGenerationWithDeterminantValues && !$0.ivs.isEmpty }
        let readyCatches = battlers.filter { BattlerAssessment(caught: $0, moveCategories: moveCategories).badges.contains(.battleReady) }
        return [
            makeMatching(.battleReady, .battle, readyCatches),
            makeMatching(.fullTeam, .battle, readyCatches, targets: [6], countsProgress: true),
            makeMatching(.perfection, .battle, battlers.filter { $0.ivs.perfectCount == Stat.allCases.count }),
            makeMatching(.fullyTrained, .battle, context.caught.filter { BattlerAssessment(caught: $0, moveCategories: moveCategories).isFullyTrained }),
            makeMatching(.trickRoomSpecialist, .battle, battlers.filter { BattlerAssessment(caught: $0, moveCategories: moveCategories).isTrickRoomBattler }),
            makeSetByDistinct(.natureLover, .battle, target: Nature.allCases.count, context.caught) { $0.nature },
            makeSetByDistinct(.hiddenPowerCollector, .battle, target: HiddenPower.types.count, battlers) { HiddenPower.findType(for: $0.ivs) }
        ]
    }

    // MARK: Features

    fileprivate static func evaluateFeatures(_ context: Context) -> [Achievement] {
        let facts = context.facts
        return [
            Achievement(kind: .journeyman, category: .features, targets: [1], value: facts.completedJourneyCount),
            Achievement(kind: .bingo, category: .features, targets: [1], value: facts.completedBingoLineCount),
            Achievement(kind: .blackout, category: .features, targets: [1], value: facts.blackoutBoardCount),
            makeTieredByDistinct(.nicknamer, .features, targets: [10], context.caught.filter { $0.nickname != nil }) { $0.id },
            Achievement(kind: .archivist, category: .features, targets: [1], value: facts.hasAutomaticBackups ? 1 : 0)
        ]
    }

    // MARK: Odds

    fileprivate static func evaluateOdds(_ context: Context) -> [Achievement] {
        let plainHunts = context.caught.compactMap { caught -> (caught: Catch, odds: Int)? in
            guard caught.huntMethod == .Encounters, let odds = CatchOdds.getOdds(for: caught), exactOdds.contains(odds) else { return nil }
            return (caught, odds)
        }
        func findHunts(where isMatch: (Int, Int) -> Bool) -> [Catch] {
            return plainHunts.filter { isMatch($0.caught.encounters, $0.odds) }.map { $0.caught }
        }
        return [
            makeMatching(.byTheBook, .odds, findHunts { $0 == $1 && $1 == CatchOdds.fullOdds }, isHidden: true),
            makeMatching(.modernClassic, .odds, findHunts { $0 == $1 && $1 == CatchOdds.fullOdds / 2 }, isHidden: true),
            makeMatching(.halfwayThere, .odds, findHunts { $0 * 2 == $1 }),
            makeMatching(.doubleTrouble, .odds, findHunts { $0 == $1 * 2 }),
            makeMatching(.tripleThreat, .odds, findHunts { $0 == $1 * 3 })
        ]
    }

    // MARK: Secrets

    fileprivate static func evaluateSecrets(_ context: Context) -> [Achievement] {
        let calendar = context.facts.calendar
        let newYearsCatches = context.caught.filter { caught in
            caught.caughtDate.map { calendar.component(.month, from: $0) == 1 && calendar.component(.day, from: $0) == 1 } ?? false
        }
        return [
            makeMatching(.palindrome, .secret, context.caught.filter { isPalindrome($0.encounters) }, isHidden: true),
            makeMatching(.midnightSparkle, .secret, newYearsCatches, isHidden: true),
            makeMatching(.roundNumber, .secret, context.caught.filter { roundEncounterCounts.contains($0.encounters) }, isHidden: true)
        ]
    }

    static func isPalindrome(_ encounters: Int) -> Bool {
        let digits = String(encounters)
        return encounters >= minimumPalindromeEncounters && digits == String(digits.reversed())
    }

    // MARK: Builders

    fileprivate static func makeMatching(_ kind: AchievementKind, _ category: AchievementCategory, _ catches: [Catch], value: Int? = nil, targets: [Int] = [1],
                                         isHidden: Bool = false, countsProgress: Bool = false) -> Achievement {
        return Achievement(kind: kind, category: category, targets: targets, value: value ?? catches.count, isHidden: isHidden, countsProgress: countsProgress,
                           catchIds: CatchRules.sortedOldestFirst(catches).map { $0.id })
    }

    fileprivate static func makeTieredByDistinct<Key: Hashable>(_ kind: AchievementKind, _ category: AchievementCategory, targets: [Int], _ catches: [Catch],
                                                                countsProgress: Bool = true, key: (Catch) -> Key?) -> Achievement {
        var seen = Set<Key>()
        var tierCatchIds = [UUID]()
        for caught in CatchRules.sortedOldestFirst(catches) {
            guard let value = key(caught), seen.insert(value).inserted else { continue }
            if (targets.contains(seen.count)) {
                tierCatchIds.append(caught.id)
            }
        }
        return Achievement(kind: kind, category: category, targets: targets, value: seen.count, countsProgress: countsProgress, catchIds: tierCatchIds)
    }

    fileprivate static func makeSetByDistinct<Key: Hashable>(_ kind: AchievementKind, _ category: AchievementCategory, target: Int, _ catches: [Catch],
                                                             key: (Catch) -> Key?) -> Achievement {
        var seen = Set<Key>()
        var memberIds = [UUID]()
        for caught in CatchRules.sortedOldestFirst(catches) {
            guard let value = key(caught), seen.insert(value).inserted else { continue }
            memberIds.append(caught.id)
        }
        return Achievement(kind: kind, category: category, targets: [target], value: seen.count, countsProgress: true, catchIds: memberIds)
    }

    fileprivate struct Context {
        let facts: AchievementFacts
        let caught: [Catch]

        init(facts: AchievementFacts) {
            self.facts = facts
            caught = facts.catches.filter { !$0.isFailed }
        }
    }
}
