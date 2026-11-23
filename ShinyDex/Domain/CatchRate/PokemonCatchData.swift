import Foundation

struct CatchProfile: Equatable {
    let catchRate: Int
    let types: [String]
    let weightInHectograms: Int
    var isInMoonStoneLine = false

    var weightInKilograms: Double {
        return Double(weightInHectograms) / 10
    }
}

struct SpeciesCatchProfiles: Equatable {
    let standard: CatchProfile
    let profilesByFormId: [String: CatchProfile]
}

struct PokemonCatchData {
    private let profilesByNumber: [Int: SpeciesCatchProfiles]

    init(profilesByNumber: [Int: SpeciesCatchProfiles] = [:]) {
        self.profilesByNumber = profilesByNumber
    }

    func findProfile(of number: Int, formId: String?) -> CatchProfile? {
        guard let species = profilesByNumber[number] else { return nil }
        return formId.flatMap { species.profilesByFormId[$0] } ?? species.standard
    }
}
