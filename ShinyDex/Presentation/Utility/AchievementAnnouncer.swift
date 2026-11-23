import UIKit

enum AchievementAnnouncer {
    static func announceNewUnlocks(using container: AppContainer) {
        let unlocked = container.claimNewAchievements.handle(ClaimNewAchievementsCommand())
        guard let first = unlocked.first else { return }
        Haptics.playSuccess()
        let completesAnAchievement = unlocked.contains { $0.tier == $0.achievement.targets.count }
        PopupHandler().showAchievementPopup(text: unlocked.count == 1 ? makeText(for: first) : "\(unlocked.count) achievements unlocked!", isMajor: completesAnAchievement)
    }

    static func makeText(for unlocked: UnlockedAchievement) -> String {
        let achievement = unlocked.achievement
        let tier = achievement.targets.count > 1 ? " · tier \(unlocked.tier) of \(achievement.targets.count)" : ""
        return "Achievement unlocked: \(achievement.title)\(tier)"
    }
}
