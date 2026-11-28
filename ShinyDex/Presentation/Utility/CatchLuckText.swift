import Foundation

enum CatchLuckText {
    static func describe(chanceOfFindingSooner chance: Double) -> String {
        return "\(summarize(chanceOfFindingSooner: chance)) of hunts at these odds"
    }

    static func summarize(chanceOfFindingSooner chance: Double) -> String {
        if (chance <= 50) {
            return "Luckier than \(formatPercent(100 - chance))"
        }
        return "Took longer than \(formatPercent(chance))"
    }

    static func formatRank(chanceOfFindingSooner chance: Double) -> String {
        return chance <= 50 ? "Top \(formatPercent(chance))" : "Bottom \(formatPercent(100 - chance))"
    }

    static func formatPercent(_ percent: Double) -> String {
        if (percent >= 1 && percent < 99.5) {
            return "\(Int(percent.rounded()))%"
        }
        let tenths = (percent * 10 * 1_000_000).rounded() / 1_000_000
        return String(format: "%.1f%%", (percent < 1 ? tenths.rounded(.up) : tenths.rounded(.down)) / 10)
    }
}
