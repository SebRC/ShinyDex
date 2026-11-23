import Foundation

struct BaseStats: Equatable {
    let values: [Int]

    init(_ values: [Int]) {
        self.values = values
    }

    subscript(stat: Stat) -> Int {
        return values[stat.rawValue]
    }
}

struct SpeciesBaseStats: Equatable {
    let standard: BaseStats
    let statsByFormId: [String: BaseStats]
}

struct PokemonBaseStats {
    private let statsByNumber: [Int: SpeciesBaseStats]

    init(statsByNumber: [Int: SpeciesBaseStats] = [:]) {
        self.statsByNumber = statsByNumber
    }

    func findStats(of number: Int, formId: String?) -> BaseStats? {
        guard let species = statsByNumber[number] else { return nil }
        return formId.flatMap { species.statsByFormId[$0] } ?? species.standard
    }
}
