import UIKit

extension BattlerBadge {
    var title: String {
        switch self {
        case .battleReady: return "Battle ready"
        case .trickRoom: return "Trick Room"
        case .natureAgainstIt: return "Nature works against it"
        case .needsEVTraining(let remaining): return "\(remaining) EVs to train"
        case .wastedEVs(let amount): return "\(amount) EVs wasted"
        case .hyperTrainingCandidate(let stats): return "Hyper Train \(stats.map { $0.shortName }.joined(separator: ", "))"
        }
    }

    var symbolName: String {
        switch self {
        case .battleReady: return "checkmark.seal.fill"
        case .trickRoom: return "tortoise.fill"
        case .natureAgainstIt: return "exclamationmark.triangle.fill"
        case .needsEVTraining: return "dumbbell.fill"
        case .wastedEVs: return "drop.fill"
        case .hyperTrainingCandidate: return "crown.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .battleReady: return Color.success
        case .trickRoom, .hyperTrainingCandidate: return Color.accent
        case .natureAgainstIt, .wastedEVs: return Color.danger
        case .needsEVTraining: return Color.textTertiary
        }
    }
}

extension BattlerRanking {
    var title: String {
        switch self {
        case .relevantIVs: return "Relevant"
        case .perfectIVs: return "Perfect"
        case .ivTotal: return "Total"
        case .readiness: return "Ready"
        }
    }

    var scoreCaption: String {
        switch self {
        case .relevantIVs: return "RELEVANT IVS"
        case .perfectIVs: return "PERFECT IVS"
        case .ivTotal: return "IV TOTAL"
        case .readiness: return "READINESS"
        }
    }
}

extension BattlerSummary {
    var title: String {
        return nickname ?? speciesTitle
    }

    var speciesTitle: String {
        return PokemonSprites.makeTitle(pokemonName: pokemonName, formName: formName)
    }

    func formatScore(for ranking: BattlerRanking) -> String {
        switch ranking {
        case .relevantIVs: return "\(relevantIVPercent)%"
        case .perfectIVs: return "\(perfectCount)/\(Stat.allCases.count)"
        case .ivTotal: return "\(ivTotal)"
        case .readiness: return "\(readiness)"
        }
    }

    func makeDetails(textColor: UIColor, font: UIFont) -> NSAttributedString {
        let details = NSMutableAttributedString()
        let separator = NSAttributedString(string: " · ", attributes: [.foregroundColor: Color.textQuaternary, .font: font])
        let parts = [nature.map { "\($0.name) (\($0.effectSummary))" } ?? "No nature", ability].compactMap { $0 }
        for (index, part) in parts.enumerated() {
            if (index > 0) {
                details.append(separator)
            }
            details.append(NSAttributedString(string: part, attributes: [.foregroundColor: textColor, .font: font]))
        }
        if let hiddenPowerType = hiddenPowerType {
            details.append(separator)
            details.append(NSAttributedString(string: "Hidden Power ", attributes: [.foregroundColor: textColor, .font: font]))
            details.append(NSAttributedString(string: hiddenPowerType, attributes: [.foregroundColor: MoveTypes.colors[hiddenPowerType] ?? textColor, .font: font]))
        }
        return details
    }

    func makeBadgeText(font: UIFont) -> NSAttributedString {
        let text = NSMutableAttributedString()
        var shownBadges = badges.map { (title: $0.title, symbolName: $0.symbolName, color: $0.color) }
        if (duplicateCount > 0) {
            shownBadges.append((title: duplicateCount == 1 ? "1 more caught" : "\(duplicateCount) more caught", symbolName: "square.stack.fill", color: Color.textTertiary))
        }
        for (index, badge) in shownBadges.enumerated() {
            if (index > 0) {
                text.append(NSAttributedString(string: "   ", attributes: [.font: font]))
            }
            let symbolConfiguration = UIImage.SymbolConfiguration(font: font)
            if let symbol = UIImage(systemName: badge.symbolName, withConfiguration: symbolConfiguration)?.withTintColor(badge.color, renderingMode: .alwaysOriginal) {
                text.append(NSAttributedString(attachment: NSTextAttachment(image: symbol)))
                text.append(NSAttributedString(string: "\u{00A0}", attributes: [.font: font]))
            }
            text.append(NSAttributedString(string: badge.title.replacingOccurrences(of: " ", with: "\u{00A0}"), attributes: [.foregroundColor: badge.color, .font: font]))
        }
        return text
    }
}
