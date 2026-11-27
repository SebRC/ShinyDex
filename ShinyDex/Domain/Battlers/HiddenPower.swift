import Foundation

struct HiddenPower: Equatable {
    static let types = ["Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel",
                        "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark"]
    static let generations = 3...7
    static let lastGenerationWithVaryingPower = 5
    static let fixedPower = 60
    static let lowestVaryingPower = 30
    static let varyingPowerRange = 40
    fileprivate static let bitOrder: [Stat] = [.hp, .attack, .defense, .speed, .specialAttack, .specialDefense]
    fileprivate static let largestWeightedSum = (1 << bitOrder.count) - 1

    let type: String
    let power: Int

    init?(ivs: IndividualValues, game: Games) {
        let generation = GamesList.games[game]?.generation ?? 0
        guard HiddenPower.generations.contains(generation),
              let type = HiddenPower.findType(for: ivs),
              let powerBits = HiddenPower.weightBits(of: ivs, at: 1) else { return nil }
        self.type = type
        power = generation <= HiddenPower.lastGenerationWithVaryingPower
            ? powerBits * HiddenPower.varyingPowerRange / HiddenPower.largestWeightedSum + HiddenPower.lowestVaryingPower
            : HiddenPower.fixedPower
    }

    static func findType(for ivs: IndividualValues) -> String? {
        return weightBits(of: ivs, at: 0).map { types[$0 * (types.count - 1) / largestWeightedSum] }
    }

    fileprivate static func weightBits(of ivs: IndividualValues, at bitPosition: Int) -> Int? {
        var weighted = 0
        for (index, stat) in bitOrder.enumerated() {
            guard let iv = ivs[stat] else { return nil }
            weighted += ((iv >> bitPosition) & 1) << index
        }
        return weighted
    }
}
