import Foundation

struct GetLinkableBingoCatchesQuery {
    let boardId: BingoBoardID
    let cellIndex: Int
}

final class GetLinkableBingoCatchesHandler {
    private let bingoBoardRepository: BingoBoardRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let evolutions: Evolutions

    init(bingoBoardRepository: BingoBoardRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, evolutions: Evolutions) {
        self.bingoBoardRepository = bingoBoardRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.evolutions = evolutions
    }

    func handle(_ query: GetLinkableBingoCatchesQuery) -> [CatchSummary] {
        guard let board = bingoBoardRepository.find(query.boardId) else { return [] }
        let mapper = CatchSummaryMapper(allPokemon: pokemonRepository.getAll())
        let links = BingoCatchLinks(catches: catchRepository.getAll(), evolutions: evolutions)
        return links.findLinkableCatches(at: query.cellIndex, in: board).compactMap(mapper.makeSummary)
    }
}
