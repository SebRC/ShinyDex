import Foundation

protocol KeyValueStore {
    func getBool(forKey key: String) -> Bool
    func set(_ value: Bool, forKey key: String)
}
