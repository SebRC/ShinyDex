import Foundation

enum PokemonLocationsLoader {
    private struct StoredLocations: Decodable {
        let strings: [String]
        let games: [String: [String: [[Int]]]]
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonLocations {
        guard let data = resourceLoader.loadData(ofResource: "pokemonLocations", withExtension: "json"),
              let stored = try? JSONDecoder().decode(StoredLocations.self, from: data) else {
            return PokemonLocations()
        }
        let strings = stored.strings
        func text(at index: Int) -> String {
            return strings.indices.contains(index) ? strings[index] : ""
        }
        var locationsByGame = [Games: [Int: [EncounterLocation]]]()
        for (gameName, speciesLocations) in stored.games {
            guard let game = Games(rawValue: gameName) else { continue }
            var byNumber = [Int: [EncounterLocation]]()
            for (nationalNumber, rows) in speciesLocations {
                guard let national = Int(nationalNumber) else { continue }
                byNumber[national - 1] = rows.filter { $0.count >= 6 }.map { row in
                    let condition = text(at: row[5])
                    let extras = Array(row.dropFirst(6)) + Array(repeating: 0, count: max(0, 17 - row.count))
                    let boosts = [(EncounterAbility.staticAbility, extras[2]), (EncounterAbility.magnetPull, extras[3])]
                        .filter { $0.1 > 0 }
                        .map { EncounterLocation.AbilityBoost(ability: $0.0, ratePercent: $0.1) }
                    return EncounterLocation(area: text(at: row[0]), method: text(at: row[1]), minimumLevel: row[2], maximumLevel: row[3],
                                             ratePercent: row[4], condition: condition.isEmpty ? nil : condition,
                                             repelTrick: extras[1] > 0 ? EncounterLocation.RepelTrick(leadLevel: extras[0], ratePercent: extras[1],
                                                                                                         withPressureRatePercent: extras[6] > 0 ? extras[6] : nil,
                                                                                                         encounterPercent: extras[8] > 0 ? extras[8] : 100,
                                                                                                         withPressureEncounterPercent: extras[9] > 0 ? extras[9] : nil) : nil,
                                             abilityBoosts: boosts,
                                             keenEyeBoost: extras[5] > 0 ? EncounterLocation.KeenEyeBoost(leadLevel: extras[4], ratePercent: extras[5]) : nil,
                                             isShinyLocked: extras[7] == 1, isSpedUpByAbilities: extras[10] == 1)
                }
            }
            locationsByGame[game] = byNumber
        }
        return PokemonLocations(locationsByGame: locationsByGame)
    }
}
