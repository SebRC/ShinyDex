import Foundation

struct GetPhaseCandidatesQuery {
    let catchId: CatchID
}

final class GetPhaseCandidatesHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let forms: PokemonForms
    private let genders: PokemonGenders

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, forms: PokemonForms = PokemonForms(), genders: PokemonGenders = PokemonGenders()) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.forms = forms
        self.genders = genders
    }

    func handle(_ query: GetPhaseCandidatesQuery) -> [CatchSummary] {
        let catches = catchRepository.getAll()
        let allPokemon = pokemonRepository.getAll()
        let links = PhaseLinks(catches: catches, pokemon: allPokemon)
        let mapper = CatchSummaryMapper(allPokemon: allPokemon, forms: forms, genders: genders)
        return catches
            .filter { links.canLink($0.id, to: query.catchId.rawValue) }
            .sorted { ($0.caughtDate ?? .distantPast) > ($1.caughtDate ?? .distantPast) }
            .compactMap(mapper.makeSummary)
    }
}
