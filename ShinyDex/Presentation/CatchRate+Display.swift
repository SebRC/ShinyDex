import UIKit

extension CatchStatus {
    var symbolName: String {
        switch self {
        case .none: return "minus"
        case .sleep: return "moon.zzz.fill"
        case .freeze: return "snowflake"
        case .paralysis: return "bolt.fill"
        case .poison: return "drop.fill"
        case .burn: return "flame.fill"
        }
    }

    func makeImage() -> UIImage? {
        let image = UIImage.makeSymbol(symbolName, pointSize: 15, weight: .semibold)
        image?.accessibilityLabel = title
        return image
    }

    var title: String {
        switch self {
        case .none: return "No status"
        case .sleep: return "Asleep"
        case .freeze: return "Frozen"
        case .paralysis: return "Paralysed"
        case .poison: return "Poisoned"
        case .burn: return "Burned"
        }
    }
}

extension EncounterPlace {
    var title: String {
        switch self {
        case .land: return "Land"
        case .cave: return "Cave"
        case .surfing: return "Surfing"
        case .fishing: return "Fishing"
        }
    }
}

extension BallCatchRate {
    var ballName: String {
        return BallGrid.getFullName(of: ball)
    }

    var formattedChance: String {
        return CatchRateFormat.formatPercent(chance)
    }

    var bonusSummary: String? {
        guard !bonus.alwaysCatches else { return nil }
        let condition = bonus.condition.map(CatchRateFormat.describe)
        var parts = [String]()
        if (bonus.multiplier != 1) {
            parts.append("×\(CatchRateFormat.formatMultiplier(bonus.multiplier))")
        }
        if (bonus.catchRateChange != 0) {
            parts.append("\(bonus.catchRateChange > 0 ? "+" : "")\(bonus.catchRateChange) catch rate")
        }
        if let condition = condition, !parts.isEmpty {
            parts.append(condition)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    var expectedThrowsText: String {
        guard chance < 1 else { return "Always catches" }
        guard let expectedThrows = expectedThrows else { return "Can't catch" }
        return expectedThrows < 1.05 ? "About 1 throw" : "About \(Int(expectedThrows.rounded(.up))) throws"
    }

    var throwsSummary: String {
        guard chance < 1, expectedThrows != nil else { return expectedThrowsText }
        return "\(expectedThrowsText) · \(CatchRateFormat.formatPercent(chanceWithinFive)) within 5 · \(CatchRateFormat.formatPercent(chanceWithinTen)) within 10"
    }
}

enum CatchRateFormat {
    static func formatPercent(_ chance: Double) -> String {
        let percent = chance * 100
        if (percent >= 99.95) {
            return chance >= 1 ? "100%" : ">99.9%"
        }
        if (percent > 0 && percent < 0.1) {
            return "<0.1%"
        }
        return String(format: percent < 10 ? "%.1f%%" : "%.0f%%", percent)
    }

    static func formatMultiplier(_ multiplier: Double) -> String {
        return multiplier == multiplier.rounded() ? String(Int(multiplier)) : String(format: "%.1f", multiplier)
    }

    static func describe(_ condition: BallCondition) -> String {
        switch condition {
        case .guaranteed: return "Always catches"
        case .type(let type): return "\(type.capitalizingFirstLetter()) type"
        case .surfingOrFishing: return "Surfing or fishing"
        case .fishing: return "Fishing"
        case .lowLevel(let level): return "Level \(level)"
        case .caughtBefore: return "Caught before in this game"
        case .turnsPassed(let turns): return turns == 1 ? "1 turn in" : "\(turns) turns in"
        case .nightOrCave: return "Night or cave"
        case .firstTurn: return "First turn"
        case .fastPokemon(let baseSpeed): return "Base Speed \(baseSpeed)"
        case .levelAdvantage: return "Your Pokémon's level"
        case .weight(let kilograms): return String(format: "%.1f kg", kilograms)
        case .sameSpeciesOppositeGender: return "Same species, opposite gender"
        case .moonStoneLine: return "Moon Stone evolution line"
        case .asleep: return "Asleep"
        case .ultraBeast: return "Ultra Beast"
        case .notUltraBeast: return "Not an Ultra Beast"
        }
    }
}
