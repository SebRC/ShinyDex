import Foundation

struct GetGameChoicesQuery {
    let number: Int?
    var keeping: Games? = nil
}

struct GameChoice: Equatable {
    enum Availability: Equatable {
        case catchable
        case shinyLocked
        case tradeOnly
        case unavailable
    }

    let game: Games
    let availability: Availability
    let isApproximate: Bool
}

final class GetGameChoicesHandler {
    private let availability: GameAvailability

    init(availability: GameAvailability) {
        self.availability = availability
    }

    func handle(_ query: GetGameChoicesQuery) -> [GameChoice] {
        guard let number = query.number else {
            return Games.allCases.map { GameChoice(game: $0, availability: .catchable, isApproximate: false) }
        }
        return Games.allCases.compactMap { game in
            let choice = GameChoice(game: game, availability: GetGameChoicesHandler.map(availability.findAvailability(of: number, in: game)),
                                    isApproximate: availability.isApproximate(game))
            return choice.availability != .unavailable || game == query.keeping ? choice : nil
        }
    }

    private static func map(_ availability: PokemonAvailability) -> GameChoice.Availability {
        switch availability {
        case .catchable: return .catchable
        case .shinyLocked: return .shinyLocked
        case .tradeOnly: return .tradeOnly
        case .unavailable: return .unavailable
        }
    }
}
