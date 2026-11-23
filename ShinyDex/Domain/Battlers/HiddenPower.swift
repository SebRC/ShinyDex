import Foundation

enum HiddenPower {
    static let types = ["Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel",
                        "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark"]
    fileprivate static let bitOrder: [Stat] = [.hp, .attack, .defense, .speed, .specialAttack, .specialDefense]

    static func findType(for ivs: IndividualValues) -> String? {
        var weightedOddBits = 0
        for (bitIndex, stat) in bitOrder.enumerated() {
            guard let iv = ivs[stat] else { return nil }
            weightedOddBits += (iv % 2) << bitIndex
        }
        let largestWeightedSum = (1 << bitOrder.count) - 1
        return types[weightedOddBits * (types.count - 1) / largestWeightedSum]
    }
}
