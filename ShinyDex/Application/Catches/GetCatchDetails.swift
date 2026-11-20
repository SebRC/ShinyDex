import Foundation

struct GetCatchDetailsQuery {
    let catchId: CatchID
}

final class GetCatchDetailsHandler {
    private let forms: PokemonForms
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let evolutions: Evolutions

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, evolutions: Evolutions, forms: PokemonForms = PokemonForms()) {
        self.forms = forms
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.evolutions = evolutions
    }

    func handle(_ query: GetCatchDetailsQuery) -> CatchDetails? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue) else { return nil }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll(), forms: forms)
        guard let summary = mapper.makeSummary(of: caught) else { return nil }
        let speciesCatches = caught.isFailed ? [] : CatchRules.sortedOldestFirst(catchRepository.getAll(number: caught.number)).filter { !$0.isFailed }
        let position = speciesCatches.count > 1 ? speciesCatches.firstIndex { $0.id == caught.id } : nil
        let targets = caught.isFailed ? [] : evolutions.getEvolutionTargets(of: caught.number).compactMap { number in
            mapper.namesByNumber[number].map { NamedPokemon(number: number, name: $0) }
        }
        return CatchDetails(
            summary: summary,
            evolvedFromName: caught.evolvedFrom.flatMap { mapper.namesByNumber[$0] },
            evolutionTargets: targets,
            odds: CatchOdds.getOdds(for: caught),
            chanceOfFindingSooner: CatchOdds.calculateChanceOfFindingSooner(caught),
            position: position,
            speciesCatchCount: speciesCatches.count,
            formChoices: FormChoices(forms.getForms(of: caught.number)))
    }
}
