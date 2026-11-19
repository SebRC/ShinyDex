import Foundation

protocol KeyValueStore {
    func bool(forKey key: String) -> Bool
    func set(_ value: Bool, forKey key: String)
}
