import UIKit

enum HuntSuggestionText {
    static func describe(_ suggestion: HuntSuggestionSummary) -> String {
        let target = suggestion.isDifferentStage ? " for \(suggestion.targetName)" : ""
        let method = suggestion.isFullOdds ? "Full odds" : suggestion.method.rawValue
        return "\(method)\(target) in \(suggestion.game.displayName) · 1/\(suggestion.odds.grouped)"
    }

    static func describeWithArea(_ suggestion: HuntSuggestionSummary) -> String {
        return ([describe(suggestion)] + [suggestion.area].compactMap { $0 }).joined(separator: " · ")
    }
}

extension HuntSuggestionMode {
    var title: String {
        switch self {
        case .fullOdds: return "Full Odds"
        case .bestOdds: return "Best Odds"
        }
    }

    var subtitle: String {
        switch self {
        case .fullOdds: return "Plain encounters in the games you play"
        case .bestOdds: return "The method and game with the best odds"
        }
    }
}

enum HuntSuggestionModeMenu {
    static func makeButton(selected: HuntSuggestionMode, onChoose: @escaping (HuntSuggestionMode) -> Void) -> UIBarButtonItem {
        let actions = HuntSuggestionMode.allCases.map { mode in
            UIAction(title: mode.title, subtitle: mode.subtitle, state: mode == selected ? .on : .off) { _ in onChoose(mode) }
        }
        let button = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: UIMenu(title: "Hunt suggestions", children: actions))
        button.accessibilityLabel = "Hunt suggestions"
        return button
    }
}
