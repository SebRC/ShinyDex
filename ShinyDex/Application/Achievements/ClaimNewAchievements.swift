import Foundation

struct ClaimNewAchievementsCommand {}

struct UnlockedAchievement: Equatable {
    let achievement: Achievement
    let tier: Int
}

final class ClaimNewAchievementsHandler {
    static let hasClaimedExistingKey = "didClaimExistingAchievements_v1"

    private let getAchievements: GetAchievementsHandler
    private let keyValueStore: KeyValueStore

    init(getAchievements: GetAchievementsHandler, keyValueStore: KeyValueStore) {
        self.getAchievements = getAchievements
        self.keyValueStore = keyValueStore
    }

    func handle(_ command: ClaimNewAchievementsCommand) -> [UnlockedAchievement] {
        let isFirstClaim = !keyValueStore.getBool(forKey: ClaimNewAchievementsHandler.hasClaimedExistingKey)
        var newlyUnlocked = [UnlockedAchievement]()
        for achievement in getAchievements.handle(GetAchievementsQuery()).achievements {
            for tier in stride(from: 1, through: achievement.unlockedTierCount, by: 1) {
                let key = ClaimNewAchievementsHandler.makeClaimKey(for: achievement.kind, tier: tier)
                guard !keyValueStore.getBool(forKey: key) else { continue }
                keyValueStore.set(true, forKey: key)
                newlyUnlocked.append(UnlockedAchievement(achievement: achievement, tier: tier))
            }
        }
        keyValueStore.set(true, forKey: ClaimNewAchievementsHandler.hasClaimedExistingKey)
        return isFirstClaim ? [] : newlyUnlocked
    }

    static func makeClaimKey(for kind: AchievementKind, tier: Int) -> String {
        return "achievementClaimed.\(String(describing: kind)).\(tier)"
    }
}
