import Foundation

enum HuntSuggestionMode: CaseIterable {
    case fullOdds
    case bestOdds
}

struct HuntSuggestion: Equatable {
    let target: Int
    let game: Games
    let method: HuntMethod
    let odds: Int
    let area: String?
}

struct HuntSuggester {
    static let maximumLegendaryCatchRate = 3
    fileprivate static let unsuggestedMethods: Set<HuntMethod> = [.Gen2Breeding, .FriendSafari]
    fileprivate static let nonWildMethods: Set<String> = ["Gift", "Gift egg", "In-game trade", "Static encounter", "Horde encounter", "Max Raid Battle", "Dynamax Adventure"]

    let locations: PokemonLocations
    let availability: GameAvailability
    let evolutions: Evolutions
    let catchData: PokemonCatchData
    let odds: OddsService

    func suggest(for number: Int, preferring preferredGames: [Games], mode: HuntSuggestionMode = .bestOdds, for journeyGame: Games? = nil) -> HuntSuggestion? {
        let catchableGames = Games.allCases.filter { availability.findAvailability(of: number, in: $0) == .catchable }
        let options: [HuntSuggestion]
        var preferredGames = preferredGames
        if let journeyGame = journeyGame {
            guard TradeGroups.canObtain(number, for: journeyGame) else { return nil }
            let canLookIn = { (game: Games) in self.locations.hasData(for: game) || catchableGames.contains(game) }
            let partners = TradeGroups.findPartners(of: journeyGame)
            let partnerOptions = partners.filter(canLookIn).flatMap { findOptions(for: number, in: $0, mode: mode) }
            preferredGames = partners
            options = partnerOptions.isEmpty ? TradeGroups.findTransferSources(for: journeyGame).filter(canLookIn).flatMap { findOptions(for: number, in: $0, mode: mode) } : partnerOptions
        }
        else {
            let preferredOptions = preferredGames.filter(catchableGames.contains).flatMap { findOptions(for: number, in: $0, mode: mode) }
            options = preferredOptions.isEmpty ? catchableGames.flatMap { findOptions(for: number, in: $0, mode: mode) } : preferredOptions
        }
        let rankOf = { (game: Games) in preferredGames.firstIndex(of: game) ?? Int.max }
        let generationOf = { (game: Games) in GamesList.games[game]?.generation ?? 0 }
        return options.min { lhs, rhs in
            let oddsOrder = (lhs.odds, rhs.odds)
            let rankOrder = (rankOf(lhs.game), rankOf(rhs.game))
            let orders = mode == .bestOdds ? [oddsOrder, rankOrder] : [rankOrder, oddsOrder]
            for (left, right) in orders where left != right {
                return left < right
            }
            return generationOf(lhs.game) > generationOf(rhs.game)
        }
    }

    fileprivate func findOptions(for number: Int, in game: Games, mode: HuntSuggestionMode) -> [HuntSuggestion] {
        guard let details = GamesList.games[game] else { return [] }
        let methods = mode == .fullOdds ? [.Encounters] : details.availableMethods.filter { !HuntSuggester.unsuggestedMethods.contains($0) }
        var options = [HuntSuggestion]()
        if locations.hasData(for: game) {
            let targets = [number] + findAncestors(of: number)
            if let (target, rows) = targets.lazy.map({ ($0, self.findHuntableRows(of: $0, in: game)) }).first(where: { !$0.1.isEmpty }) {
                for method in methods where method != .Masuda {
                    let matching = rows.filter { HuntSuggester.isRow($0, suitedTo: method) }
                    guard !matching.isEmpty else { continue }
                    options.append(makeSuggestion(target: target, game: game, method: method, area: HuntSuggester.findBestArea(in: matching), mode: mode))
                }
            }
            else if availability.findAvailability(of: number, in: game) == .catchable {
                options.append(makeSuggestion(target: number, game: game, method: .Encounters, area: nil, mode: mode))
            }
            let lineCanBeFound = ([number] + evolutions.getLine(of: number)).contains { !findHuntableRows(of: $0, in: game).isEmpty }
                || availability.findAvailability(of: number, in: game) == .catchable
            if methods.contains(.Masuda), lineCanBeFound, canBreed(number) {
                options.append(makeSuggestion(target: evolutions.getRoot(of: number), game: game, method: .Masuda, area: nil, mode: mode))
            }
        }
        else {
            options.append(makeSuggestion(target: number, game: game, method: .Encounters, area: nil, mode: mode))
            if methods.contains(.Masuda), canBreed(number) {
                options.append(makeSuggestion(target: evolutions.getRoot(of: number), game: game, method: .Masuda, area: nil, mode: mode))
            }
        }
        return options
    }

    fileprivate func makeSuggestion(target: Int, game: Games, method: HuntMethod, area: String?, mode: HuntSuggestionMode) -> HuntSuggestion {
        let configuration = HuntConfiguration(game: game, generation: GamesList.games[game]?.generation ?? 0, huntMethod: method,
                                              isShinyCharmActive: mode == .bestOdds).normalized()
        return HuntSuggestion(target: target, game: game, method: method, odds: odds.getShinyOdds(configuration: configuration, chain: configuration.chainForBestOdds), area: area)
    }

    fileprivate func findHuntableRows(of number: Int, in game: Games) -> [EncounterLocation] {
        return locations.findLocations(of: number, in: game).filter { !$0.isShinyLocked && $0.method != "In-game trade" }
    }

    fileprivate func findAncestors(of number: Int) -> [Int] {
        var ancestors = [Int]()
        var current = number
        while let parent = evolutions.getParent(of: current), !ancestors.contains(parent) {
            ancestors.append(parent)
            current = parent
        }
        return ancestors
    }

    fileprivate func canBreed(_ number: Int) -> Bool {
        let catchRate = catchData.findProfile(of: evolutions.getRoot(of: number), formId: nil)?.catchRate ?? 0
        return catchRate > HuntSuggester.maximumLegendaryCatchRate
    }

    fileprivate static func isRow(_ row: EncounterLocation, suitedTo method: HuntMethod) -> Bool {
        let isWild = !nonWildMethods.contains(row.method) && !row.method.hasPrefix("Roaming")
        switch method {
        case .Encounters: return true
        case .ChainFishing: return row.method.contains("Rod")
        case .Pokeradar: return row.method == "Grass or cave"
        case .DexNav: return isWild && !row.method.contains("Rod")
        case .SosChaining: return row.method.hasPrefix("SOS call")
        case .Lure: return row.method.hasPrefix("Overworld")
        case .Masuda, .Gen2Breeding, .FriendSafari: return false
        }
    }

    fileprivate static func findBestArea(in rows: [EncounterLocation]) -> String? {
        return rows.max { ($0.ratePercent == 0 ? 100 : $0.ratePercent) < ($1.ratePercent == 0 ? 100 : $1.ratePercent) }?.area
    }
}
