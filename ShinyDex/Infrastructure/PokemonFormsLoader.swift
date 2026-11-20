import Foundation

enum PokemonFormsLoader {
    private struct Entry: Decodable {
        struct Form: Decodable {
            let id: String
            let name: String
        }

        let number: Int
        let defaultName: String?
        let forms: [Form]
    }

    static func load(from resourceLoader: ResourceLoader) -> PokemonForms {
        guard let data = resourceLoader.loadData(ofResource: "forms", withExtension: "json"),
              let entries = try? JSONDecoder().decode([Entry].self, from: data) else {
            return PokemonForms()
        }
        let formsByNumber = Dictionary(entries.map { entry in
            (entry.number, SpeciesForms(defaultName: entry.defaultName, alternates: entry.forms.map { PokemonForm(id: $0.id, name: $0.name) }))
        }, uniquingKeysWith: { first, _ in first })
        return PokemonForms(formsByNumber: formsByNumber)
    }
}
