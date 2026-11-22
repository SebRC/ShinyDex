import Foundation

struct PokemonGenders {
    fileprivate static let mixedGenders: [Gender] = [.male, .female]

    fileprivate let fixedGendersByNumber: [Int: Gender]

    init(fixedGendersByNumber: [Int: Gender] = [:]) {
        self.fixedGendersByNumber = fixedGendersByNumber
    }

    func findFixedGender(of number: Int) -> Gender? {
        return fixedGendersByNumber[number]
    }

    func findPossibleGenders(of number: Int) -> [Gender] {
        return findFixedGender(of: number).map { [$0] } ?? PokemonGenders.mixedGenders
    }

    func resolve(_ gender: Gender?, for number: Int) -> Gender? {
        if let fixedGender = findFixedGender(of: number) {
            return fixedGender
        }
        return gender.flatMap { PokemonGenders.mixedGenders.contains($0) ? $0 : nil }
    }
}
