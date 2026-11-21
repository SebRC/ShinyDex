import Foundation

final class EncounterLedger {
    private(set) var total: Int
    let trackedSince: Date

    init(total: Int, trackedSince: Date) {
        self.total = total
        self.trackedSince = trackedSince
    }

    convenience init(startingOn date: Date) {
        self.init(total: 0, trackedSince: date)
    }

    func count(_ encounters: Int) {
        total += max(encounters, 0)
    }

    func uncount(_ encounters: Int, keepingAtLeast floor: Int) {
        total = max(total - max(encounters, 0), min(floor, total))
    }
}
