import Foundation

struct ReachedMilestone: Equatable {
    enum Kind: Equatable {
        case oddsMultiple(Int)
        case encounters(Int)
    }

    let number: Int
    let pokemonName: String
    let kind: Kind

    var isOddsMilestone: Bool {
        if case .oddsMultiple = kind { return true }
        return false
    }
}

extension ReachedMilestone {
    init(number: Int, pokemonName: String, milestone: EncounterMilestone) {
        self.number = number
        self.pokemonName = pokemonName
        switch milestone {
        case .oddsMultiple(let multiple): kind = .oddsMultiple(multiple)
        case .encounters(let encounters): kind = .encounters(encounters)
        }
    }
}
