import Foundation

final class UserDefaultsStore: KeyValueStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getBool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getDate(forKey key: String) -> Date? {
        return userDefaults.object(forKey: key) as? Date
    }

    func set(_ date: Date?, forKey key: String) {
        userDefaults.set(date, forKey: key)
    }
}
