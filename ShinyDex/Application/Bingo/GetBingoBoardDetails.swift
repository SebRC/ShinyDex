import Foundation

struct GetBingoBoardDetailsQuery {
    let boardId: BingoBoardID
}

final class GetBingoBoardDetailsHandler {
    private let forms: PokemonForms
    private let bingoBoardRepository: BingoBoardRepository
    private let catchRepository: CatchRepository
    private let pokemonRepository: PokemonRepository
    private let evolutions: Evolutions

    init(bingoBoardRepository: BingoBoardRepository, catchRepository: CatchRepository, pokemonRepository: PokemonRepository, evolutions: Evolutions, forms: PokemonForms = PokemonForms()) {
        self.forms = forms
        self.bingoBoardRepository = bingoBoardRepository
        self.catchRepository = catchRepository
        self.pokemonRepository = pokemonRepository
        self.evolutions = evolutions
    }

    func handle(_ query: GetBingoBoardDetailsQuery) -> BingoBoardDetails? {
        guard let board = bingoBoardRepository.find(query.boardId) else { return nil }
        let allPokemon = pokemonRepository.getAll()
        let mapper = CatchSummaryMapper(allPokemon: allPokemon, forms: forms)
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
                isInCompletedLine: indexesInCompletedLines.contains(index),
                formId: cell.formId,
                formName: cell.number.flatMap { forms.findForm(cell.formId, of: $0)?.name })
        }
        return BingoBoardDetails(id: query.boardId, name: board.name, size: board.size, cells: cells, completedLineCount: completedLines.count)
    }
}
