import Foundation

struct RestoreBackupCommand {
    let data: Data
}

final class RestoreBackupHandler {
    private let backupRepository: BackupRepository
    private let pokemonRepository: PokemonRepository

    init(backupRepository: BackupRepository, pokemonRepository: PokemonRepository) {
        self.backupRepository = backupRepository
        self.pokemonRepository = pokemonRepository
    }

    func handle(_ command: RestoreBackupCommand) throws {
        let document = try BackupDocument.decode(from: command.data)
        let catches = document.makeCatches()
        let backup = Backup(
            pokemon: makeChangedPokemon(from: document.pokemon, catches: catches),
            catches: catches,
            hunts: document.makeHunts(),
            journeys: document.makeJourneys(),
            bingoBoards: document.makeBingoBoards(),
            activeMoves: document.makeActiveMoves(),
            encounterLedger: document.makeEncounterLedger(),
            yearlyGoals: document.makeYearlyGoals())
        try backupRepository.replaceAll(with: backup)
    }

    private func makeChangedPokemon(from records: [BackupDocument.PokemonRecord], catches: [Catch]) -> [Pokemon] {
        let recordsByNumber = Dictionary(records.map { ($0.number, $0) }, uniquingKeysWith: { _, last in last })
        let caughtByNumber = Dictionary(grouping: catches.filter { !$0.isFailed }, by: { $0.number })
        return pokemonRepository.getAll().compactMap { current in
            let restored = Pokemon(newlyAddedNamed: current.name, number: current.number)
            if let record = recordsByNumber[current.number] {
                RestoreBackupHandler.apply(record, to: restored)
            }
            let caught = caughtByNumber[current.number] ?? []
            restored.caughtBall = CatchRules.getLatestBall(of: caught)
            restored.caughtDescription = caught.isEmpty ? "Not Caught" : "Caught"
            return RestoreBackupHandler.hasSameState(restored, current) ? nil : restored
        }
    }

    private static func apply(_ record: BackupDocument.PokemonRecord, to pokemon: Pokemon) {
        pokemon.encounters = record.encounters
        pokemon.isBeingHunted = record.isBeingHunted
        pokemon.generation = record.generation
        pokemon.isShinyCharmActive = record.isShinyCharmActive
        pokemon.shinyOdds = record.shinyOdds
        pokemon.huntMethod = record.huntMethod
        pokemon.increment = record.increment
        pokemon.game = record.game
        pokemon.chain = record.chain ?? pokemon.huntConfiguration.makeChainFromLegacyEncounters(record.encounters)
    }

    private static func hasSameState(_ first: Pokemon, _ second: Pokemon) -> Bool {
        return first.encounters == second.encounters
            && first.chain == second.chain
            && first.isBeingHunted == second.isBeingHunted
            && first.generation == second.generation
            && first.isShinyCharmActive == second.isShinyCharmActive
            && first.shinyOdds == second.shinyOdds
            && first.huntMethod == second.huntMethod
            && first.increment == second.increment
            && first.game == second.game
            && first.caughtBall == second.caughtBall
            && first.caughtDescription == second.caughtDescription
    }
}
