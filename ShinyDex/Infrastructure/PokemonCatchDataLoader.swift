import Foundation

enum PokemonCatchDataLoader {
    private struct Profile: Decodable {
        let types: [String]
        let weight: Int
    }

    private struct Entry: Decodable {
        let number: Int
        let catchRate: Int
        let types: [String]
        let weight: Int
        let moonStoneFamily: Bool?
        let forms: [String: Profile]?
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonCatchData {
        guard let data = resourceLoader.loadData(ofResource: "catchData", withExtension: "json"),
              let entries = try? JSONDecoder().decode([Entry].self, from: data) else {
            return PokemonCatchData()
        }
        let profilesByNumber = Dictionary(entries.map { entry in
            let isInMoonStoneLine = entry.moonStoneFamily ?? false
            let standard = CatchProfile(catchRate: entry.catchRate, types: entry.types, weightInHectograms: entry.weight, isInMoonStoneLine: isInMoonStoneLine)
            let forms = (entry.forms ?? [:]).mapValues {
                CatchProfile(catchRate: entry.catchRate, types: $0.types, weightInHectograms: $0.weight, isInMoonStoneLine: isInMoonStoneLine)
            }
            return (entry.number, SpeciesCatchProfiles(standard: standard, profilesByFormId: forms))
        }, uniquingKeysWith: { first, _ in first })
        return PokemonCatchData(profilesByNumber: profilesByNumber)
    }
}
