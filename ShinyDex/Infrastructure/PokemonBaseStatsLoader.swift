import Foundation

enum PokemonBaseStatsLoader {
    private struct Entry: Decodable {
        let number: Int
        let stats: [Int]
        let forms: [String: [Int]]?
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonBaseStats {
        guard let data = resourceLoader.loadData(ofResource: "baseStats", withExtension: "json"),
              let entries = try? JSONDecoder().decode([Entry].self, from: data) else {
            return PokemonBaseStats()
        }
        let statCount = Stat.allCases.count
        let statsByNumber = Dictionary(entries.filter { $0.stats.count == statCount }.map { entry in
            let formStats = (entry.forms ?? [:]).filter { $0.value.count == statCount }.mapValues(BaseStats.init)
            return (entry.number, SpeciesBaseStats(standard: BaseStats(entry.stats), statsByFormId: formStats))
        }, uniquingKeysWith: { first, _ in first })
        return PokemonBaseStats(statsByNumber: statsByNumber)
    }
}
