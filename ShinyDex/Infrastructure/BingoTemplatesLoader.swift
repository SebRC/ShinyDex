import Foundation

enum BingoTemplatesLoader {
    private struct StoredTemplate: Decodable {
        let id: String
        let name: String
        let pokemon: [String]?
        let formId: String?
        let formsOf: String?
    }

    static func load(from resourceLoader: ResourceLoader, pokemonNames: [String], forms: PokemonForms) -> BingoTemplates {
        guard let data = resourceLoader.loadData(ofResource: "bingoTemplates", withExtension: "json"),
              let stored = try? JSONDecoder().decode([StoredTemplate].self, from: data) else {
            return BingoTemplates()
        }
        let numbersByName = Dictionary(pokemonNames.enumerated().map { ($0.element, $0.offset) }, uniquingKeysWith: { first, _ in first })
        return BingoTemplates(templates: stored.map { template in
            BingoTemplate(id: template.id, name: template.name, entries: makeEntries(of: template, numbersByName: numbersByName, pokemonCount: pokemonNames.count, forms: forms))
        })
    }

    private static func makeEntries(of template: StoredTemplate, numbersByName: [String: Int], pokemonCount: Int, forms: PokemonForms) -> [BingoEntry] {
        if let names = template.pokemon {
            return names.compactMap { numbersByName[$0].map { BingoEntry(number: $0, formId: nil) } }
        }
        if let formId = template.formId {
            return (0..<pokemonCount).compactMap { number in forms.findForm(formId, of: number).map { BingoEntry(number: number, formId: $0.id) } }
        }
        if let speciesName = template.formsOf, let number = numbersByName[speciesName] {
            let alternates = forms.getForms(of: number)?.alternates ?? []
            return [BingoEntry(number: number, formId: nil)] + alternates.map { BingoEntry(number: number, formId: $0.id) }
        }
        return []
    }
}
