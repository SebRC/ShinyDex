import Foundation

struct GetBingoBoardDetailsQuery {
    let boardId: BingoBoardID
}

final class GetBingoBoardDetailsHandler {
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

    func handle(_ query: GetBingoBoardDetailsQuery) -> BingoBoardDetails? {
        guard let board = bingoBoardRepository.find(query.boardId) else { return nil }
        let allPokemon = pokemonRepository.getAll()
        let mapper = CatchSummaryMapper(allPokemon: allPokemon)
        let links = BingoCatchLinks(catches: catchRepository.getAll(), evolutions: evolutions)
        let completedLines = board.findCompletedLines(in: links.catchesById)
        let indexesInCompletedLines = Set(completedLines.joined())
        let cells = board.cells.enumerated().map { index, cell -> BingoCellDetails in
            let linked = board.findLinkedCatch(at: index, in: links.catchesById)
            return BingoCellDetails(
                index: index,
                number: cell.number,
                pokemonName: cell.number.flatMap { allPokemon[safe: $0]?.name },
                linkedCatch: linked.flatMap(mapper.makeSummary),
                linkableCatchCount: linked == nil ? links.findLinkableCatches(at: index, in: board).count : 0,
                isInCompletedLine: indexesInCompletedLines.contains(index))
        }
        return BingoBoardDetails(id: query.boardId, name: board.name, size: board.size, cells: cells, completedLineCount: completedLines.count)
    }
}
