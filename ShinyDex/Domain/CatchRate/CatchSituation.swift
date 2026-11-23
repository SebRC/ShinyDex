import Foundation

enum CatchStatus: CaseIterable {
    case none
    case sleep
    case freeze
    case paralysis
    case poison
    case burn

    func findBonus(inGeneration generation: Int) -> Double {
        switch self {
        case .none: return 1
        case .sleep, .freeze: return generation >= 5 ? 2.5 : 2
        case .paralysis, .poison, .burn: return 1.5
        }
    }
}

enum EncounterPlace: CaseIterable {
    case land
    case cave
    case surfing
    case fishing
}

struct CatchSituation: Equatable {
    static let hpPercentRange = 1...100
    static let firstTurn = 1

    var hpPercent = 100
    var isAtOneHP = false
    var status = CatchStatus.none
    var level = 50
    var turn = CatchSituation.firstTurn
    var isNight = false
    var place = EncounterPlace.land
    var yourLevel = 50
    var isSameSpeciesOppositeGender = false
    var isRegisteredAsCaught = false
}
