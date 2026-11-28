import Foundation

enum BackupFileError: Error, Equatable {
    case unreadable
    case newerFormat
}

struct BackupDocument: Codable {
    static let currentFormatVersion = 1

    struct PokemonRecord: Codable {
        let number: Int
        let encounters: Int
        let chain: Int?
        let isBeingHunted: Bool
        let generation: Int
        let isShinyCharmActive: Bool
        let shinyOdds: Int
        let huntMethod: HuntMethod
        let increment: Int
        let game: Games
        var phases: [PhaseRecord]? = nil
    }

    struct CatchRecord: Codable {
        let id: UUID
        let number: Int
        let caughtBall: String
        let game: Games
        let huntMethod: HuntMethod
        let encounters: Int
        let isShinyCharmActive: Bool
        let caughtDate: Date?
        let isFailed: Bool
        let evs: String?
        let evolvedFrom: Int?
        let nickname: String?
        let gender: Gender?
        let nature: Nature?
        let ivs: String?
        let formId: String?
        let encounterTotalAtFind: Int?
        var ability: String? = nil
        var moves: [Int]? = nil
        var level: Int? = nil
        var phaseCatchIds: [UUID]? = nil
    }

    struct PhaseRecord: Codable {
        let catchId: UUID
        let encounters: Int
    }

    struct HuntRecord: Codable {
        let id: UUID
        let name: String
        let pokemonNumbers: [Int]
        let priority: Int
        let isCollapsed: Bool
    }

    struct JourneyEntryRecord: Codable {
        let id: UUID
        let number: Int
        let catchId: UUID?
        let phaseCatchIds: [UUID]
        let formId: String?
    }

    struct JourneyRecord: Codable {
        let id: UUID
        let name: String
        let createdDate: Date
        let priority: Int
        let entries: [JourneyEntryRecord]
        var game: String? = nil
    }

    struct BingoCellRecord: Codable {
        let number: Int?
        let catchId: UUID?
        let formId: String?
    }

    struct BingoBoardRecord: Codable {
        let id: UUID
        let name: String
        let createdDate: Date
        let priority: Int
        let size: BingoBoardSize
        let cells: [BingoCellRecord]
    }

    struct MoveRecord: Codable {
        let name: String
        let maxPP: Int
        let remainingPP: Int
        let type: String
    }

    struct ActiveMovesRecord: Codable {
        let moves: [MoveRecord]
        let pressureActive: Bool
    }

    struct EncounterLedgerRecord: Codable {
        let total: Int
        let trackedSince: Date
    }

    struct YearlyGoalRecord: Codable {
        let year: Int
        let target: Int
    }

    struct DailyEncountersRecord: Codable {
        let day: String
        let count: Int
        var pokemon: [String: Int]? = nil
    }

    struct TeamRecord: Codable {
        let id: UUID
        let name: String
        let memberIds: [UUID]
        let createdDate: Date
    }

    private struct FormatHeader: Decodable {
        let formatVersion: Int
    }

    let formatVersion: Int
    let createdDate: Date
    let pokemon: [PokemonRecord]
    let catches: [CatchRecord]
    let hunts: [HuntRecord]
    let journeys: [JourneyRecord]
    let bingoBoards: [BingoBoardRecord]
    let activeMoves: ActiveMovesRecord?
    let encounterLedger: EncounterLedgerRecord?
    let yearlyGoals: [YearlyGoalRecord]?
    let dailyEncounters: [DailyEncountersRecord]?
    var teams: [TeamRecord]? = nil

    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(BackupDocument.makeDateFormatter().string(from: date))
        }
        return try encoder.encode(self)
    }

    static func decode(from data: Data) throws -> BackupDocument {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            guard let date = makeDateFormatter().date(from: text) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date \(text)")
            }
            return date
        }
        guard let header = try? decoder.decode(FormatHeader.self, from: data) else { throw BackupFileError.unreadable }
        guard header.formatVersion <= currentFormatVersion else { throw BackupFileError.newerFormat }
        guard let document = try? decoder.decode(BackupDocument.self, from: data) else { throw BackupFileError.unreadable }
        return document
    }

    private static func makeDateFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

extension Games: Codable {}
extension HuntMethod: Codable {}
extension Gender: Codable {}
extension Nature: Codable {}
extension BingoBoardSize: Codable {}

extension BackupDocument {
    init(pokemon: [Pokemon], catches: [Catch], hunts: [Hunt], journeys: [Journey], bingoBoards: [BingoBoard], activeMoves: ActiveMoves?,
         encounterLedger: EncounterLedger?, yearlyGoals: [YearlyGoal], dailyEncounters: [DailyEncounters], teams: [Team] = [], createdDate: Date) {
        formatVersion = BackupDocument.currentFormatVersion
        self.createdDate = createdDate
        self.pokemon = pokemon.map {
            PokemonRecord(number: $0.number, encounters: $0.encounters, chain: $0.chain, isBeingHunted: $0.isBeingHunted, generation: $0.generation, isShinyCharmActive: $0.isShinyCharmActive,
                          shinyOdds: $0.shinyOdds, huntMethod: $0.huntMethod, increment: $0.increment, game: $0.game,
                          phases: $0.phases.isEmpty ? nil : $0.phases.map { PhaseRecord(catchId: $0.catchId, encounters: $0.encounters) })
        }
        self.catches = catches.map {
            CatchRecord(id: $0.id, number: $0.number, caughtBall: $0.caughtBall, game: $0.game, huntMethod: $0.huntMethod, encounters: $0.encounters,
                        isShinyCharmActive: $0.isShinyCharmActive, caughtDate: $0.caughtDate, isFailed: $0.isFailed,
                        evs: $0.evs.isEmpty ? nil : $0.evs.encoded, evolvedFrom: $0.evolvedFrom, nickname: $0.nickname,
                        gender: $0.gender, nature: $0.nature, ivs: $0.ivs.isEmpty ? nil : $0.ivs.encoded, formId: $0.formId,
                        encounterTotalAtFind: $0.encounterTotalAtFind, ability: $0.ability, moves: $0.moves.isEmpty ? nil : $0.moves, level: $0.level,
                        phaseCatchIds: $0.phaseCatchIds.isEmpty ? nil : $0.phaseCatchIds)
        }
        self.hunts = hunts.map {
            HuntRecord(id: $0.id, name: $0.name, pokemonNumbers: $0.indexes, priority: $0.priority, isCollapsed: $0.isCollapsed)
        }
        self.journeys = journeys.map { journey in
            JourneyRecord(id: journey.id, name: journey.name, createdDate: journey.createdDate, priority: journey.priority,
                          entries: journey.entries.map { JourneyEntryRecord(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds, formId: $0.formId) },
                          game: journey.game?.rawValue)
        }
        self.bingoBoards = bingoBoards.map { board in
            BingoBoardRecord(id: board.id, name: board.name, createdDate: board.createdDate, priority: board.priority, size: board.size,
                             cells: board.cells.map { BingoCellRecord(number: $0.number, catchId: $0.catchId, formId: $0.formId) })
        }
        self.activeMoves = activeMoves.map { activeMoves in
            ActiveMovesRecord(moves: activeMoves.moves.map { MoveRecord(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) },
                              pressureActive: activeMoves.pressureActive)
        }
        self.encounterLedger = encounterLedger.map { EncounterLedgerRecord(total: $0.total, trackedSince: $0.trackedSince) }
        self.yearlyGoals = yearlyGoals.map { YearlyGoalRecord(year: $0.year, target: $0.target) }
        self.teams = teams.map { TeamRecord(id: $0.id, name: $0.name, memberIds: $0.memberIds, createdDate: $0.createdDate) }
        self.dailyEncounters = dailyEncounters.map { encounters in
            DailyEncountersRecord(day: encounters.day.isoDate, count: encounters.count,
                                  pokemon: encounters.countsByPokemon.isEmpty ? nil : Dictionary(uniqueKeysWithValues: encounters.countsByPokemon.map { (String($0.key), $0.value) }))
        }
    }

    func makeCatches() -> [Catch] {
        return catches.map {
            Catch(id: $0.id, number: $0.number, caughtBall: $0.caughtBall, game: $0.game, huntMethod: $0.huntMethod, encounters: $0.encounters,
                  isShinyCharmActive: $0.isShinyCharmActive, caughtDate: $0.caughtDate, isFailed: $0.isFailed, evs: EffortValues(encoded: $0.evs),
                  evolvedFrom: $0.evolvedFrom, nickname: $0.nickname, gender: $0.gender, nature: $0.nature, ivs: IndividualValues(encoded: $0.ivs), formId: $0.formId,
                  encounterTotalAtFind: $0.encounterTotalAtFind, ability: $0.ability, moves: $0.moves ?? [], level: $0.level, phaseCatchIds: $0.phaseCatchIds ?? [])
        }
    }

    func makeHunts() -> [Hunt] {
        return hunts.map { Hunt(id: $0.id, name: $0.name, indexes: $0.pokemonNumbers, priority: $0.priority, isCollapsed: $0.isCollapsed) }
    }

    func makeJourneys() -> [Journey] {
        return journeys.map { journey in
            Journey(id: journey.id, name: journey.name, createdDate: journey.createdDate, priority: journey.priority,
                    entries: journey.entries.map { JourneyEntry(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds, formId: $0.formId) },
                    game: journey.game.flatMap(Games.init))
        }
    }

    func makeBingoBoards() -> [BingoBoard] {
        return bingoBoards.map { board in
            BingoBoard(id: board.id, name: board.name, createdDate: board.createdDate, priority: board.priority, size: board.size,
                       cells: board.cells.map { BingoCell(number: $0.number, catchId: $0.catchId, formId: $0.formId) })
        }
    }

    func makeActiveMoves() -> ActiveMoves? {
        return activeMoves.map { record in
            ActiveMoves(moves: record.moves.map { ActiveMove(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) },
                        pressureActive: record.pressureActive)
        }
    }

    func makeEncounterLedger() -> EncounterLedger? {
        return encounterLedger.map { EncounterLedger(total: $0.total, trackedSince: $0.trackedSince) }
    }

    func makeDailyEncounters() -> [DailyEncounters]? {
        return dailyEncounters.map { records in
            records.compactMap { record in
                EncounterDay(isoDate: record.day).map { day in
                    let countsByPokemon = (record.pokemon ?? [:]).compactMap { key, value in Int(key).map { ($0, value) } }
                    return DailyEncounters(day: day, count: record.count, countsByPokemon: Dictionary(countsByPokemon, uniquingKeysWith: +))
                }
            }
        }
    }

    func makeTeams() -> [Team]? {
        return teams.map { records in records.map { Team(id: $0.id, name: $0.name, memberIds: $0.memberIds, createdDate: $0.createdDate) } }
    }

    func makeYearlyGoals() -> [YearlyGoal]? {
        return yearlyGoals.map { records in records.map { YearlyGoal(year: $0.year, target: $0.target) } }
    }
}
