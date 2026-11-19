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

    func deleteAll() {
        stored.removeAll()
    }

    static func copy(_ pokemon: Pokemon) -> Pokemon {
        return Pokemon(name: pokemon.name, number: pokemon.number, encounters: pokemon.encounters, caughtDescription: pokemon.caughtDescription,
                       caughtBall: pokemon.caughtBall, isBeingHunted: pokemon.isBeingHunted, generation: pokemon.generation,
                       isShinyCharmActive: pokemon.isShinyCharmActive, shinyOdds: pokemon.shinyOdds, huntMethod: pokemon.huntMethod,
                       increment: pokemon.increment, game: pokemon.game)
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
                     isFailed: caught.isFailed, evs: caught.evs, evolvedFrom: caught.evolvedFrom)
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

    func deleteAll() {
        stored = nil
    }
}

final class InMemoryKeyValueStore: KeyValueStore {
    private(set) var values = [String: Bool]()

    func bool(forKey key: String) -> Bool {
        return values[key] ?? false
    }

    func set(_ value: Bool, forKey key: String) {
        values[key] = value
    }
}

final class StubResourceLoader: ResourceLoader {
    var textResources = [String: [String]]()
    var dataResources = [String: Data]()

    func lines(ofTextResource name: String) -> [String] {
        return textResources[name] ?? []
    }

    func data(ofResource name: String, withExtension fileExtension: String) -> Data? {
        return dataResources["\(name).\(fileExtension)"]
    }
}
