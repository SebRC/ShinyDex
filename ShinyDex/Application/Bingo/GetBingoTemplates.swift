import Foundation

struct GetBingoTemplatesQuery {}

struct BingoTemplateSummary: Equatable {
    let id: String
    let name: String
    let pokemonCount: Int
    let coverPokemonName: String?
    let coverFormId: String?
}

final class GetBingoTemplatesHandler {
    private let templates: BingoTemplates
    private let pokemonRepository: PokemonRepository

    init(templates: BingoTemplates, pokemonRepository: PokemonRepository) {
        self.templates = templates
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ query: GetBingoTemplatesQuery) -> [BingoTemplateSummary] {
        let allPokemon = pokemonRepository.getAll()
        return templates.templates.filter { !$0.entries.isEmpty }.map { template in
            let cover = template.entries.first
            return BingoTemplateSummary(id: template.id,
                                        name: template.name,
                                        pokemonCount: template.entries.count,
                                        coverPokemonName: cover.flatMap { allPokemon[safe: $0.number]?.name },
                                        coverFormId: cover?.formId)
        }
    }
}
