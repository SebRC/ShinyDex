import Foundation

enum AchievementCategory: Int, CaseIterable {
    case collecting
    case hunting
    case consistency
    case games
    case battle
    case features
    case odds
    case secret
}

enum AchievementKind: Hashable {
    case firstSparkle
    case shinyHoarder
    case regionalMaster(region: Int)
    case livingDex
    case formFanatic
    case familyReunion
    case genderBalance
    case ballCollector
    case apricornAesthetic
    case masterClass

    case dedicated
    case marathon
    case lightningStrike
    case firstTry
    case beatTheOdds
    case againstAllOdds
    case methodActor
    case charmed
    case multitasker
    case itGotAway
    case unfinishedBusiness

    case dailyGrind
    case goalGetter
    case overachiever
    case drySpellSurvivor
    case anniversary
    case everyMonth

    case generational
    case timeTraveller
    case retro
    case sameGameTwice

    case battleReady
    case fullTeam
    case goodGenes
    case perfection
    case fullyTrained
    case trickRoomSpecialist
    case natureLover
    case hiddenPowerCollector

    case journeyman
    case bingo
    case blackout
    case nicknamer
    case archivist

    case byTheBook
    case modernClassic
    case halfwayThere
    case doubleTrouble
    case tripleThreat

    case palindrome
    case midnightSparkle
    case roundNumber
}

struct Achievement: Equatable {
    let kind: AchievementKind
    let category: AchievementCategory
    let targets: [Int]
    let value: Int
    var isHidden = false
    var countsProgress = false
    var catchIds = [UUID]()

    var unlockedTierCount: Int {
        return targets.filter { value >= $0 }.count
    }

    var isUnlocked: Bool {
        return unlockedTierCount > 0
    }

    var isComplete: Bool {
        return unlockedTierCount == targets.count
    }

    var nextTarget: Int? {
        return targets.first { value < $0 }
    }

    var currentTarget: Int {
        return nextTarget ?? targets.last ?? 1
    }
}
