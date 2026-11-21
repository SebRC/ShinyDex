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

    @discardableResult
    func count(_ encounters: Int) -> Int {
        return changeTotal(to: total + max(encounters, 0))
    }

    @discardableResult
    func uncount(_ encounters: Int, keepingAtLeast floor: Int) -> Int {
        return changeTotal(to: max(total - max(encounters, 0), min(floor, total)))
    }

    private func changeTotal(to newTotal: Int) -> Int {
        let change = newTotal - total
        total = newTotal
        return change
    }
}
