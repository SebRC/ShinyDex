import Foundation

struct DryStreaks: Equatable {
    let current: Int
    let longest: Int
    let trackedSince: Date

    init(ledger: EncounterLedger, catches: [Catch]) {
        let boundaries = [0] + DryStreaks.findLedgerTotalsAtFind(in: catches) + [ledger.total]
        let streaks = zip(boundaries, boundaries.dropFirst()).map { max($1 - $0, 0) }
        current = streaks.last ?? 0
        longest = streaks.max() ?? 0
        trackedSince = ledger.trackedSince
    }

    static func findEndedStreaks(in catches: [Catch]) -> [Int] {
        let boundaries = [0] + findLedgerTotalsAtFind(in: catches)
        return zip(boundaries, boundaries.dropFirst()).map { max($1 - $0, 0) }
    }

    static func findLatestLedgerTotalAtFind(in catches: [Catch]) -> Int? {
        return findLedgerTotalsAtFind(in: catches).last
    }

    private static func findLedgerTotalsAtFind(in catches: [Catch]) -> [Int] {
        return catches.compactMap { $0.encounterTotalAtFind }.sorted()
    }
}
