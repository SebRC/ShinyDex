import Foundation

struct CreateGeneratedBingoBoardCommand {
    enum Source: Equatable {
        case template(id: String)
        case random(region: Int?, onlyUncaught: Bool)
    }

    let name: String
    let size: BingoBoardSize
    let source: Source
}

final class CreateGeneratedBingoBoardHandler {
    private let bingoBoardRepository: BingoBoardRepository
    private let pokemonRepository: PokemonRepository
    private let catchRepository: CatchRepository
    private let templates: BingoTemplates
    private var generator: RandomNumberGenerator

    init(bingoBoardRepository: BingoBoardRepository, pokemonRepository: PokemonRepository, catchRepository: CatchRepository, templates: BingoTemplates,
         generator: RandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.bingoBoardRepository = bingoBoardRepository
        self.pokemonRepository = pokemonRepository
        self.catchRepository = catchRepository
        self.templates = templates
        self.generator = generator
    }

    func handle(_ command: CreateGeneratedBingoBoardCommand) -> BingoBoardID? {
        let pool = makePool(for: command.source)
        guard !pool.isEmpty else { return nil }
        let entries = BingoTemplates.pickEntries(from: pool, count: command.size.cellCount, using: &generator)
        let priority = (bingoBoardRepository.getAll().map { $0.priority }.max() ?? -1) + 1
        let board = BingoBoard(name: command.name, priority: priority, size: command.size, entries: entries)
        bingoBoardRepository.save(board)
        return BingoBoardID(rawValue: board.id)
    }

    private func makePool(for source: CreateGeneratedBingoBoardCommand.Source) -> [BingoEntry] {
        switch source {
        case .template(let id):
            return templates.find(id: id)?.entries ?? []
        case .random(let region, let onlyUncaught):
            let pokemonCount = pokemonRepository.getAll().count
            let numbers = region.flatMap { PokedexRegions.getNumbers(inRegion: $0) }.map(Array.init) ?? Array(0..<pokemonCount)
            let caughtNumbers = Set(CatchRules.countByNumber(catchRepository.getAll().filter { !$0.isFailed }).keys)
            return numbers
                .filter { $0 < pokemonCount && (!onlyUncaught || !caughtNumbers.contains($0)) }
                .map { BingoEntry(number: $0, formId: nil) }
        }
    }
}
