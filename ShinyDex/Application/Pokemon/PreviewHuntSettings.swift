import Foundation

struct PreviewHuntSettingsQuery {
    let settings: HuntSettings
    let encounters: Int
    var selectingGame: Games? = nil
}

struct HuntSettingsPreview: Equatable {
    let settings: HuntSettings
    let shinyOdds: Int
}

final class PreviewHuntSettingsHandler {
    private let odds: OddsService

    init(odds: OddsService) {
        self.odds = odds
    }

    func handle(_ query: PreviewHuntSettingsQuery) -> HuntSettingsPreview {
        var configuration = query.settings.configuration
        if let game = query.selectingGame {
            configuration = configuration.selecting(game)
        }
        configuration = configuration.normalized()
        return HuntSettingsPreview(settings: HuntSettings(configuration), shinyOdds: odds.getShinyOdds(configuration: configuration, encounters: query.encounters))
    }
}
