import Foundation

struct GetCatchDetailsQuery {
    let catchId: CatchID
}

final class GetCatchDetailsHandler {
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let evolutions: Evolutions

    init(catchRepository: CatchRepository, pokemonRepository: PokemonRepository, evolutions: Evolutions) {
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.evolutions = evolutions
    }

    func handle(_ query: GetCatchDetailsQuery) -> CatchDetails? {
        guard let caught = catchRepository.get(id: query.catchId.rawValue) else { return nil }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll())
        guard let summary = mapper.summary(of: caught) else { return nil }
        let speciesCatches = caught.isFailed ? [] : CatchRules.sortedOldestFirst(catchRepository.getAll(number: caught.number)).filter { !$0.isFailed }
        let position = speciesCatches.count > 1 ? speciesCatches.firstIndex { $0.id == caught.id } : nil
        let targets = caught.isFailed ? [] : evolutions.evolutionTargets(of: caught.number).compactMap { number in
            mapper.namesByNumber[number].map { NamedPokemon(number: number, name: $0) }
        }
        return CatchDetails(
            summary: summary,
            evolvedFromName: caught.evolvedFrom.flatMap { mapper.namesByNumber[$0] },
            evolutionTargets: targets,
            odds: CatchOdds.odds(for: caught),
            chanceOfFindingSooner: CatchOdds.chanceOfFindingSooner(caught),
            position: position,
            speciesCatchCount: speciesCatches.count)
    }
}
