import Foundation

protocol EncounterLedgerRepository {
    func get() -> EncounterLedger?
    func save(_ ledger: EncounterLedger)
}
