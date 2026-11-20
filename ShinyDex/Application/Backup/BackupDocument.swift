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
    init(pokemon: [Pokemon], catches: [Catch], hunts: [Hunt], journeys: [Journey], bingoBoards: [BingoBoard], activeMoves: ActiveMoves?, createdDate: Date) {
        formatVersion = BackupDocument.currentFormatVersion
        self.createdDate = createdDate
        self.pokemon = pokemon.map {
            PokemonRecord(number: $0.number, encounters: $0.encounters, chain: $0.chain, isBeingHunted: $0.isBeingHunted, generation: $0.generation, isShinyCharmActive: $0.isShinyCharmActive,
                          shinyOdds: $0.shinyOdds, huntMethod: $0.huntMethod, increment: $0.increment, game: $0.game)
        }
        self.catches = catches.map {
            CatchRecord(id: $0.id, number: $0.number, caughtBall: $0.caughtBall, game: $0.game, huntMethod: $0.huntMethod, encounters: $0.encounters,
                        isShinyCharmActive: $0.isShinyCharmActive, caughtDate: $0.caughtDate, isFailed: $0.isFailed,
                        evs: $0.evs.isEmpty ? nil : $0.evs.encoded, evolvedFrom: $0.evolvedFrom, nickname: $0.nickname,
                        gender: $0.gender, nature: $0.nature, ivs: $0.ivs.isEmpty ? nil : $0.ivs.encoded, formId: $0.formId)
        }
        self.hunts = hunts.map {
            HuntRecord(id: $0.id, name: $0.name, pokemonNumbers: $0.indexes, priority: $0.priority, isCollapsed: $0.isCollapsed)
        }
        self.journeys = journeys.map { journey in
            JourneyRecord(id: journey.id, name: journey.name, createdDate: journey.createdDate, priority: journey.priority,
                          entries: journey.entries.map { JourneyEntryRecord(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds, formId: $0.formId) })
        }
        self.bingoBoards = bingoBoards.map { board in
            BingoBoardRecord(id: board.id, name: board.name, createdDate: board.createdDate, priority: board.priority, size: board.size,
                             cells: board.cells.map { BingoCellRecord(number: $0.number, catchId: $0.catchId, formId: $0.formId) })
        }
        self.activeMoves = activeMoves.map { activeMoves in
            ActiveMovesRecord(moves: activeMoves.moves.map { MoveRecord(name: $0.name, maxPP: $0.maxPP, remainingPP: $0.remainingPP, type: $0.type) },
                              pressureActive: activeMoves.pressureActive)
        }
    }

    func makeCatches() -> [Catch] {
        return catches.map {
            Catch(id: $0.id, number: $0.number, caughtBall: $0.caughtBall, game: $0.game, huntMethod: $0.huntMethod, encounters: $0.encounters,
                  isShinyCharmActive: $0.isShinyCharmActive, caughtDate: $0.caughtDate, isFailed: $0.isFailed, evs: EffortValues(encoded: $0.evs),
                  evolvedFrom: $0.evolvedFrom, nickname: $0.nickname, gender: $0.gender, nature: $0.nature, ivs: IndividualValues(encoded: $0.ivs), formId: $0.formId)
        }
    }

    func makeHunts() -> [Hunt] {
        return hunts.map { Hunt(id: $0.id, name: $0.name, indexes: $0.pokemonNumbers, priority: $0.priority, isCollapsed: $0.isCollapsed) }
    }

    func makeJourneys() -> [Journey] {
        return journeys.map { journey in
            Journey(id: journey.id, name: journey.name, createdDate: journey.createdDate, priority: journey.priority,
                    entries: journey.entries.map { JourneyEntry(id: $0.id, number: $0.number, catchId: $0.catchId, phaseCatchIds: $0.phaseCatchIds, formId: $0.formId) })
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
}
