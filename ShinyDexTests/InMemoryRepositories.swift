import Foundation
@testable import ShinyDex

// Repositories that keep copies, so a change only sticks once it is saved, as with the Core Data versions.

final class InMemoryPokemonRepository: PokemonRepository {
    private(set) var stored = [Int: Pokemon]()

    init(names: [String] = []) {
        for (number, name) in names.enumerated() {
            insert(Pokemon(newlyAddedNamed: name, number: number))
        }
    }

    func getAll() -> [Pokemon] {
        return stored.values.sorted { $0.number < $1.number }.map(InMemoryPokemonRepository.copy)
    }

    func get(number: Int) -> Pokemon? {
        return stored[number].map(InMemoryPokemonRepository.copy)
    }

    func insert(_ pokemon: Pokemon) {
        stored[pokemon.number] = InMemoryPokemonRepository.copy(pokemon)
    }

    func save(_ pokemon: Pokemon) {
        guard stored[pokemon.number] != nil else { return }
        stored[pokemon.number] = InMemoryPokemonRepository.copy(pokemon)
    }

    static func copy(_ pokemon: Pokemon) -> Pokemon {
        let copy = Pokemon(name: pokemon.name, number: pokemon.number, encounters: pokemon.encounters, caughtDescription: pokemon.caughtDescription,
                       caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, generation: pokemon.generation,
                       isShinyCharmActive: pokemon.isShinyCharmActive, shinyOdds: pokemon.shinyOdds, huntMethod: pokemon.huntMethod,
                       increment: pokemon.increment, game: pokemon.game)
        copy.chain = pokemon.chain
        copy.phases = pokemon.phases
        return copy
    }
}

final class InMemoryCatchRepository: CatchRepository {
    private(set) var stored = [Catch]()
    private var pending: [Catch]?
    var failsToSave = false

    private var working: [Catch] {
        get { return pending ?? stored }
        set { pending = newValue }
    }

    func getAll() -> [Catch] {
        return working.map(InMemoryCatchRepository.copy)
    }

    func getAll(number: Int) -> [Catch] {
        return getAll().filter { $0.number == number }
    }

    func get(id: UUID) -> Catch? {
        return getAll().first { $0.id == id }
    }

    func insert(_ caught: Catch) {
        working.append(InMemoryCatchRepository.copy(caught))
    }

    func update(_ caught: Catch) {
        guard let index = working.firstIndex(where: { $0.id == caught.id }) else { return }
        working[index] = InMemoryCatchRepository.copy(caught)
    }

    func delete(_ caught: Catch) {
        working.removeAll { $0.id == caught.id }
    }

    @discardableResult
    func save() -> Bool {
        defer { pending = nil }
        guard !failsToSave else { return false }
        stored = working
        return true
    }

    static func copy(_ caught: Catch) -> Catch {
        return Catch(id: caught.id, number: caught.number, caughtBall: caught.caughtBall, game: caught.game, huntMethod: caught.huntMethod,
                     encounters: caught.encounters, isShinyCharmActive: caught.isShinyCharmActive, caughtDate: caught.caughtDate,
                     isFailed: caught.isFailed, evs: caught.evs, evolvedFrom: caught.evolvedFrom,
                     nickname: caught.nickname, gender: caught.gender, nature: caught.nature, ivs: caught.ivs, formId: caught.formId,
                     encounterTotalAtFind: caught.encounterTotalAtFind, ability: caught.ability, moves: caught.moves, level: caught.level, phaseCatchIds: caught.phaseCatchIds)
    }
}

final class InMemoryHuntRepository: HuntRepository {
    private(set) var stored = [Hunt]()

    func getAll() -> [Hunt] {
        return stored.map(InMemoryHuntRepository.copy)
    }

    func save(_ hunt: Hunt) {
        if let index = stored.firstIndex(where: { $0.id == hunt.id }) {
            stored[index] = InMemoryHuntRepository.copy(hunt)
        } else {
            stored.append(InMemoryHuntRepository.copy(hunt))
        }
    }

    func delete(_ hunt: Hunt) {
        stored.removeAll { $0.id == hunt.id }
    }

    func clear() {
        stored.removeAll()
    }

    static func copy(_ hunt: Hunt) -> Hunt {
        return Hunt(id: hunt.id, name: hunt.name, indexes: hunt.indexes, priority: hunt.priority, isCollapsed: hunt.isCollapsed)
    }
}

final class InMemoryJourneyRepository: JourneyRepository {
    private(set) var stored = [Journey]()

    func getAll() -> [Journey] {
        return stored.map(InMemoryJourneyRepository.copy)
    }

    @discardableResult
    func save(_ journey: Journey) -> Bool {
        if let index = stored.firstIndex(where: { $0.id == journey.id }) {
            stored[index] = InMemoryJourneyRepository.copy(journey)
        } else {
            stored.append(InMemoryJourneyRepository.copy(journey))
        }
        return true
    }

    func delete(_ journey: Journey) {
        stored.removeAll { $0.id == journey.id }
    }

    static func copy(_ journey: Journey) -> Journey {
        return Journey(id: journey.id, name: journey.name, createdDate: journey.createdDate, priority: journey.priority, entries: journey.entries)
    }
}

final class InMemoryBingoBoardRepository: BingoBoardRepository {
    private(set) var stored = [BingoBoard]()

    func getAll() -> [BingoBoard] {
        return stored.map(InMemoryBingoBoardRepository.copy)
    }

    @discardableResult
    func save(_ board: BingoBoard) -> Bool {
        if let index = stored.firstIndex(where: { $0.id == board.id }) {
            stored[index] = InMemoryBingoBoardRepository.copy(board)
        } else {
            stored.append(InMemoryBingoBoardRepository.copy(board))
        }
        return true
    }

    func delete(_ board: BingoBoard) {
        stored.removeAll { $0.id == board.id }
    }

    static func copy(_ board: BingoBoard) -> BingoBoard {
        return BingoBoard(id: board.id, name: board.name, createdDate: board.createdDate, priority: board.priority, size: board.size, cells: board.cells)
    }
}

final class InMemoryMoveRepository: MoveRepository {
    private(set) var stored: ActiveMoves?

    func getActiveMoves() -> ActiveMoves? {
        return stored.map { ActiveMoves(moves: $0.moves.map { ActiveMove(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) }, pressureActive: $0.pressureActive) }
    }

    func insert(_ activeMoves: ActiveMoves) {
        stored = activeMoves
    }

    func save(_ activeMoves: ActiveMoves) {
        stored = activeMoves
    }
}

final class InMemoryEncounterLedgerRepository: EncounterLedgerRepository {
    private(set) var stored: EncounterLedger?

    func get() -> EncounterLedger? {
        return stored.map { EncounterLedger(total: $0.total, trackedSince: $0.trackedSince) }
    }

    func save(_ ledger: EncounterLedger) {
        stored = EncounterLedger(total: ledger.total, trackedSince: ledger.trackedSince)
    }
}

final class InMemoryYearlyGoalRepository: YearlyGoalRepository {
    private(set) var stored = [YearlyGoal]()

    func getAll() -> [YearlyGoal] {
        return stored.sorted { $0.year < $1.year }
    }

    func save(_ goal: YearlyGoal) {
        stored.removeAll { $0.year == goal.year }
        stored.append(goal)
    }

    func delete(year: Int) {
        stored.removeAll { $0.year == year }
    }
}

final class InMemoryDailyEncountersRepository: DailyEncountersRepository {
    private(set) var stored = [EncounterDay: DailyEncounters]()

    func get(day: EncounterDay) -> DailyEncounters? {
        return stored[day]
    }

    func getAll() -> [DailyEncounters] {
        return stored.values.sorted { $0.day < $1.day }
    }

    func save(_ encounters: DailyEncounters) {
        stored[encounters.day] = encounters
    }

    func replaceAll(with encounters: [DailyEncounters]) {
        stored = Dictionary(encounters.map { ($0.day, $0) }, uniquingKeysWith: { _, last in last })
    }
}

final class InMemoryKeyValueStore: KeyValueStore {
    private(set) var values = [String: Bool]()
    private(set) var dates = [String: Date]()

    func getBool(forKey key: String) -> Bool {
        return values[key] ?? false
    }

    func set(_ value: Bool, forKey key: String) {
        values[key] = value
    }

    func getDate(forKey key: String) -> Date? {
        return dates[key]
    }

    func set(_ date: Date?, forKey key: String) {
        dates[key] = date
    }
}

final class InMemoryBackupFolder: BackupFolder {
    private(set) var files = [String: Data]()
    private(set) var name: String?
    var failsToWrite = false

    func choose(_ url: URL) throws {
        name = url.lastPathComponent
    }

    func forget() {
        name = nil
    }

    func write(_ file: BackupFile) throws {
        if failsToWrite { throw BackupFolderError.unreachable }
        files[file.fileName] = file.data
    }

    func listFileNames() throws -> [String] {
        return Array(files.keys)
    }

    func deleteFile(named fileName: String) throws {
        files[fileName] = nil
    }

    func addFile(named fileName: String) {
        files[fileName] = Data()
    }
}

final class StubResourceLoader: ResourceLoader {
    var textResources = [String: [String]]()
    var dataResources = [String: Data]()

    func loadLines(ofTextResource name: String) -> [String] {
        return textResources[name] ?? []
    }

    func loadData(ofResource name: String, withExtension fileExtension: String) -> Data? {
        return dataResources["\(name).\(fileExtension)"]
    }
}

final class InMemoryTeamRepository: TeamRepository {
    private(set) var stored = [Team]()

    func getAll() -> [Team] {
        return stored
    }

    func save(_ team: Team) {
        if let index = stored.firstIndex(where: { $0.id == team.id }) {
            stored[index] = team
        }
        else {
            stored.append(team)
        }
    }

    func delete(id: UUID) {
        stored.removeAll { $0.id == id }
    }
}
