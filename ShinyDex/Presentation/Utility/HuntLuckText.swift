import Foundation

struct HuntLuckText: Equatable {
    let chanceDetail: String?
    let oddsDetail: String?

    init(pokemon: PokemonDetails) {
        guard pokemon.encounters > 0 else {
            chanceDetail = nil
            oddsDetail = nil
            return
        }
        let longerPercent = HuntLuckText.formatPercent(100 - pokemon.probability)
        chanceDetail = pokemon.probability < 50 ? "\(longerPercent) of hunts go longer" : "Only \(longerPercent) of hunts go this long"
        oddsDetail = HuntLuckText.makeOddsDetail(encounters: pokemon.encounters, shinyOdds: pokemon.shinyOdds, usesChain: pokemon.usesChain)
    }

    private static func makeOddsDetail(encounters: Int, shinyOdds: Int, usesChain: Bool) -> String? {
        guard !usesChain, shinyOdds > 0, encounters >= shinyOdds else { return nil }
        let multiple = (Double(encounters) / Double(shinyOdds) * 10).rounded() / 10
        return String(format: "%.1f× past odds", multiple)
    }

    private static func formatPercent(_ percent: Double) -> String {
        if percent >= 1 && percent <= 99 {
            return "\(Int(percent.rounded()))%"
        }
        return String(format: "%.1f%%", (percent * 10).rounded(.down) / 10)
    }
}
