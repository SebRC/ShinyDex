import CoreData

final class CoreDataPokemonRepository: PokemonRepository {
    // Saving touches one row per Pokémon (over a thousand when applying settings to all), so rows are remembered by number instead of fetched each time.
    private static let identities = ManagedObjectIdentityMap<Int>()

    private let managedContext: NSManagedObjectContext
    private let entity: NSEntityDescription

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        entity = NSEntityDescription.entity(forEntityName: "PokemonEntity", in: managedContext)!
    }

    func getAll() -> [Pokemon] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PokemonEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        do {
            return try managedContext.fetch(fetchRequest).map(makePokemon)
        }
        catch let error as NSError {
            print("Could not fetch PokemonEntity table. \(error.localizedDescription)")
        }
        return []
    }

    func get(number: Int) -> Pokemon? {
        return object(for: number).map(makePokemon)
    }

    func insert(_ pokemon: Pokemon) {
        let pokemonEntity = managedContext.insertWithPermanentID(entity: entity)
        pokemonEntity.setValue(pokemon.number, forKey: "number")
        Self.identities.record(pokemon.number, for: pokemonEntity.objectID)
        write(pokemon, to: pokemonEntity)
    }

    func save(_ pokemon: Pokemon) {
        guard let pokemonEntity = object(for: pokemon.number) else {
            print("Could not save \(pokemon.name): no stored Pokémon has number \(pokemon.number).")
            return
        }
        write(pokemon, to: pokemonEntity)
    }

    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PokemonEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        }
        catch let error as NSError {
            print("An error ocurred when deleting all entities: \(error.localizedDescription)")
        }
    }

    private func object(for number: Int) -> NSManagedObject? {
        if let known = Self.identities.object(for: number, in: managedContext) {
            return known
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PokemonEntity")
        fetchRequest.predicate = NSPredicate(format: "number == %d", number)
        guard let pokemonEntity = (try? managedContext.fetch(fetchRequest))?.first else { return nil }
        Self.identities.record(number, for: pokemonEntity.objectID)
        return pokemonEntity
    }

    private func makePokemon(from pokemonEntity: NSManagedObject) -> Pokemon {
        let number = pokemonEntity.value(forKey: "number") as! Int
        Self.identities.record(number, for: pokemonEntity.objectID)
        return Pokemon(
            name: pokemonEntity.value(forKey: "name") as! String,
            number: number,
            encounters: pokemonEntity.value(forKey: "encounters") as! Int,
            caughtDescription: pokemonEntity.value(forKey: "caughtDescription") as! String,
            caughtBall: pokemonEntity.value(forKey: "caughtBall") as! String,
            isBeingHunted: pokemonEntity.value(forKey: "isBeingHunted") as? Bool ?? false,
            generation: pokemonEntity.value(forKey: "generation") as! Int,
            isShinyCharmActive: pokemonEntity.value(forKey: "isShinyCharmActive") as! Bool,
            shinyOdds: pokemonEntity.value(forKey: "shinyOdds") as! Int,
            huntMethod: HuntMethod(rawValue: pokemonEntity.value(forKey: "huntMethod") as! String)!,
            increment: pokemonEntity.value(forKey: "increment") as! Int,
            game: Games(rawValue: pokemonEntity.value(forKey: "game") as? String ?? Games.Red.rawValue) ?? Games.Red)
    }

    private func write(_ pokemon: Pokemon, to pokemonEntity: NSManagedObject) {
        pokemonEntity.setValue(pokemon.name, forKey: "name")
        pokemonEntity.setValue(pokemon.encounters, forKey: "encounters")
        pokemonEntity.setValue(pokemon.caughtDescription, forKey: "caughtDescription")
        pokemonEntity.setValue(pokemon.caughtBall, forKey: "caughtBall")
        pokemonEntity.setValue(pokemon.isBeingHunted, forKey: "isBeingHunted")
        pokemonEntity.setValue(pokemon.generation, forKey: "generation")
        pokemonEntity.setValue(pokemon.isShinyCharmActive, forKey: "isShinyCharmActive")
        pokemonEntity.setValue(pokemon.shinyOdds, forKey: "shinyOdds")
        pokemonEntity.setValue(pokemon.huntMethod.rawValue, forKey: "huntMethod")
        pokemonEntity.setValue(pokemon.increment, forKey: "increment")
        pokemonEntity.setValue(pokemon.game.rawValue, forKey: "game")
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save \(pokemon.name). \(error.localizedDescription)")
        }
    }
}
