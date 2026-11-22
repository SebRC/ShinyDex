import Foundation

enum PokemonGendersLoader {
    static func load(from resourceLoader: ResourceLoader) -> PokemonGenders {
        guard let data = resourceLoader.loadData(ofResource: "genders", withExtension: "json"),
              let stored = try? JSONDecoder().decode([String: [Int]].self, from: data) else {
            return PokemonGenders()
        }
        var fixedGendersByNumber = [Int: Gender]()
        for (genderName, numbers) in stored {
            guard let gender = Gender(rawValue: genderName) else { continue }
            numbers.forEach { fixedGendersByNumber[$0] = gender }
        }
        return PokemonGenders(fixedGendersByNumber: fixedGendersByNumber)
    }
}
