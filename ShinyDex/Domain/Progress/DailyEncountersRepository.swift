import Foundation

protocol DailyEncountersRepository {
    func get(day: EncounterDay) -> DailyEncounters?
    func getAll() -> [DailyEncounters]
    func save(_ encounters: DailyEncounters)
    func replaceAll(with encounters: [DailyEncounters])
}
