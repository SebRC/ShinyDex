import Foundation

protocol KeyValueStore {
    func getBool(forKey key: String) -> Bool
    func set(_ value: Bool, forKey key: String)
    func getDate(forKey key: String) -> Date?
    func set(_ date: Date?, forKey key: String)
}
