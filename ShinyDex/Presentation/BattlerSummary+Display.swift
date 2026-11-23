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
        var shownBadges = badges.map { (title: $0.title, symbolName: $0.symbolName, color: $0.color) }
        if (duplicateCount > 0) {
            shownBadges.append((title: duplicateCount == 1 ? "1 more caught" : "\(duplicateCount) more caught", symbolName: "square.stack.fill", color: Color.textTertiary))
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Spacing.small
        let text = NSMutableAttributedString()
        for (index, badge) in shownBadges.enumerated() {
            if (index > 0) {
                text.append(NSAttributedString(string: " ", attributes: [.font: font]))
            }
            let chip = BadgeChip.makeImage(title: badge.title, symbolName: badge.symbolName, color: badge.color, font: font)
            let attachment = NSTextAttachment(image: chip)
            attachment.bounds = CGRect(x: 0, y: (font.capHeight - chip.size.height) / 2, width: chip.size.width, height: chip.size.height)
            text.append(NSAttributedString(attachment: attachment))
        }
        text.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.length))
        return text
    }
}

enum BadgeChip {
    fileprivate static let horizontalPadding: CGFloat = 8
    fileprivate static let verticalPadding: CGFloat = 4
    fileprivate static let iconSpacing: CGFloat = 4
    fileprivate static let backgroundAlpha: CGFloat = 0.16

    static func makeImage(title: String, symbolName: String, color: UIColor, font: UIFont) -> UIImage {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let titleSize = (title as NSString).size(withAttributes: attributes)
        let icon = UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(font: font))?.withTintColor(color, renderingMode: .alwaysOriginal)
        let iconSize = icon?.size ?? .zero
        let contentHeight = max(titleSize.height, iconSize.height)
        let size = CGSize(width: ceil(horizontalPadding * 2 + iconSize.width + (icon == nil ? 0 : iconSpacing) + titleSize.width),
                          height: ceil(contentHeight + verticalPadding * 2))
        return UIGraphicsImageRenderer(size: size).image { _ in
            let background = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: CornerRadius.capsule(height: size.height))
            color.withAlphaComponent(backgroundAlpha).setFill()
            background.fill()
            var x = horizontalPadding
            if let icon = icon {
                icon.draw(at: CGPoint(x: x, y: (size.height - iconSize.height) / 2))
                x += iconSize.width + iconSpacing
            }
            (title as NSString).draw(at: CGPoint(x: x, y: (size.height - titleSize.height) / 2), withAttributes: attributes)
        }
    }
}
