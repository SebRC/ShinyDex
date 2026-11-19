import Foundation

protocol PokemonRepository {
    func getAll() -> [Pokemon]
    func get(number: Int) -> Pokemon?
    func insert(_ pokemon: Pokemon)
    func save(_ pokemon: Pokemon)
    func deleteAll()
}
